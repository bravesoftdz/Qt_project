#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <poll.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>
#include "gpios.h"
#include <QDebug>
#include <QCoreApplication>
#include <QtMath>
#include <QString>

//sodimas I/O输入总共有24个(0-23) 0无按下 1有按下
//0-11:BC0-BC11
//12-15:Elib1-Elib4
//16-23:8位拨码开关
static unsigned char PreFlag[GPIONUM];
static unsigned char LightSta[16];  //BC0-BC11 Elib1-Elib4按钮输入灯状态处理
static unsigned char GpiosValue[GPIONUM];
static int fd;
static int ledLightOffFlag[12] = {0};
static int ledLightOnFlag[12] = {0};
static unsigned char protection[16] = {0};


#define    CANOPENILE           "/dev/canopen"
#define    GPIONUM              24
#define    RAW_COUNTS           5
#define    ADC_DATA_PATH(x)     QString("/sys/devices/platform/soc/2100000.aips-bus/2198000.adc/iio:device0/in_voltage%1_raw").arg(x)

/*
v1----- 特殊按钮的短路 正常值：为0(没有按钮按下时)，按下时不短路也为0，当短路时为1
v2----- 背光按钮的短路 正常值：为0，异常值曾经出现过一个3的值，理论上大于0视为异常数值
v3----- 电源短接，正常值：value：2532，理论值接近0，判断value时，小于1000当做异常数值
v4----- 12路按钮的原理图的3,4短接，正常值：点亮几个按钮就为几，12路，
最大的正常值理论上为12，短路时测量值为38左右，判断值大于12即可
*/
static int normalValue[5] = {0, 0, 0, 1000, 12};

Gpios::Gpios(QThread *parent) : QThread(parent)
{
    mFreq = 10000;
    connect(&mProtectTimer, &QTimer::timeout, this, &Gpios::sltTimeOut);
    mProtectTimer.setInterval(mFreq);
    mProtectTimer.setSingleShot(true);
    initGpiosFd();
}

int Gpios::sysExecuteKoFile(const char *str)
{
    printf("%s %s\n", __FUNCTION__, str);
    int flag = system(str);
    printf("%s result is %d\n", __FUNCTION__, flag);
    return flag;
}

int Gpios::getFloorNum(float num)
{
    int tmp = qFloor(num);
    return  tmp;
}

void Gpios::judgeIsProtect(int index, int num)
{
//    if (num > normalValue[index])
//    {
//        allLightoff();
//        if (!mProtectTimer.isActive())
//        {
//            mProtectTimer.start();
//        }
//    }
}

void Gpios::sltTimeOut()
{

}

void Gpios::initGpiosFd()
{
    int flag;
    int sysFlag;
    memset(PreFlag, 0, 24);
    memset(LightSta, 0, 16);
    signal(SIGIO, mySignalFunc);     // 在应用程序中捕捉SIGIO信号(这个信号是驱动程序发送出来的)

    QString runPath = QString("insmod /usr/bst/usrfs/gpio-sodimas-canopen.ko");
    sysFlag = sysExecuteKoFile(runPath.toLatin1().data());    // 挂载驱动

    fd = open("/dev/canopen", O_RDWR);
    if (fd < 0)
    {
        qDebug()<<__PRETTY_FUNCTION__<<"lines = "<<__LINE__<<"can not open canopen device!";
        return;
    }
    if (sysFlag != 0)
    {
        qDebug()<<__PRETTY_FUNCTION__<<"lines = "<<__LINE__<<"load DriverFile is error!";
        return;
    }

    fcntl(fd, F_SETOWN, getpid());      // 将当前进程PID设置为fd文件所对应驱动程序将要发送SIGIO信号进程PID
    flag = fcntl(fd, F_GETFL);          // 获取fd的打开方式
    fcntl(fd, F_SETFL, flag|FASYNC);    // 将fd的打开方式设置为FASYNC, 即支持异步通知
    QThread::msleep(50);
    read(fd, GpiosValue, 24);
}

void Gpios::allLightoff()
{
    write(fd, protection, 24);
}

void Gpios::mySignalFunc(int signum)
{
    Q_UNUSED(signum);
    if (fd > 0)
    {
        read(fd, GpiosValue, 24);
    }
}

void Gpios::run()
{
    while (1)
    {
        readAdcValue();
        setPressed();
        msleep(15);
    }
}

void Gpios::getDialSwitchValue()
{
    quint8 tmpValue = 0;
    for (int i = 16; i < 24; ++i)
    {
        if (1 == GpiosValue[i])
        {
            tmpValue |= (1<<(i - 16));
        }
        else
        {
            tmpValue &= ~(1<<(i - 16));
        }
    }
    if (mDipValue != tmpValue)
    {
        mDipValue = tmpValue;
        emit sigDailChanged(mDipValue);
        qDebug()<<__FUNCTION__<< " mDipValue is changed "<< mDipValue;
    }
}

void Gpios::setPressed()
{
    unsigned char Cnt;
    for (Cnt = 0; Cnt < 17; ++Cnt) //0-11: BC0-BC11  //12-15: Elib1-Elib4
    {
        if (Cnt < 16)
        {
            if (GpiosValue[Cnt])   // 有按键按下
            {
                if (0 == PreFlag[Cnt])
                {
                    /* 可在此处将按钮信息发送给控制柜或是作为事件触发 */
                    if (Cnt < 16) // BC0-BC11 Elib1-Elib4 按钮输入灯状态处理
                    {
                        LightSta[Cnt] ^= 1;
                        if (LightSta[Cnt])
                        {
                            if (Cnt < 12)
                            {
                                printf("btn%d is pressed\n", Cnt);
                                //                                    emit sigBtnPressed(Cnt+1);
                            }
                            else if (Cnt < 16)
                            {
                                printf("btn%d is pressed\n", Cnt+25);
                                //                                    emit sigBtnPressed(Cnt+25);
                            }
                            setLight(1, Cnt);
                        }
                        else
                        {
                            if (Cnt < 12)
                            {
                                printf("btn%d is cancled\n", Cnt);
                                //                                    emit sigBtnCanceld(Cnt+1);
                            }
                            else if (Cnt < 16)
                            {
                                //                                    emit sigBtnCanceld(Cnt+25);
                                printf("btn%d is cancled\n", Cnt+25);
                            }
                            setLight(0, Cnt);
                        }
                    }
                }
                PreFlag[Cnt] = 1;  // 记录按下标志
            }
            else
            {
                if (PreFlag[Cnt])   // 松开按键
                {
                    if (Cnt < 12)
                    {
                        //                            emit sigBtnReleased(Cnt+1);
                        PreFlag[Cnt] = 0; // 清除按下标志
                    }
                    else if (Cnt < 16)
                    {
                        //                            emit sigBtnReleased(Cnt+25);
                        PreFlag[Cnt] = 0; // 清除按下标志
                    }
                } /*end of if(PreFlag[Cnt])*/
            }
        }
    }


}

void Gpios::setLight(unsigned char c, unsigned char pos)
{
    lseek(fd, pos, SEEK_SET);
    write(fd, &c, 1);
}

void Gpios::readAdcValue()
{
    int fd, ret;
    qreal vref = 3.36;
    double voltage;
    double get_value;
    char data[20];
    for (int i = 1; i < RAW_COUNTS; ++i)
    {
        const char* tmp = ADC_DATA_PATH(i).toLatin1().data();
        //        printf("tmp = volatage%d_raw\n", i);
        fd = open(tmp, O_RDONLY);
        if (fd < 0)
        {
            perror("open AI8_DATA_PATH error");
            return;
        }
        ret = read(fd, data, sizeof(data));
        if (ret < 0)
        {
            perror("read data error");
            return;
        }
        /* collect data and calculate the voltage */
        get_value = atof(data);

        judgeIsProtect(i, getFloorNum(get_value));
        voltage = vref * (get_value / 4096);
        if (i == 1)
        {
            printf("get value%d: %f\n", i, get_value);
            printf("voltage%d: %.6f\n", i, voltage);
        }
        close(fd);
    }
}