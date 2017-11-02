/* Using an SPI ADC (e.g., the MCP3008)
* Written by Derek Molloy for the book "Exploring Raspberry Pi" */
#include <iostream>
#include <cstdio>
#include <fcntl.h>
#include <errno.h> 
/* Not technically required, but needed on some UNIX distributions */
#include <sys/types.h>
#include <sys/stat.h>

#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

int fd_is_valid(int fd)
{
    return fcntl(fd, F_GETFD) != -1 || errno != EBADF;
}

extern "C" {
int simioctl(int fd, unsigned long cmd, unsigned long arg)
{
   struct spi_ioc_transfer *ioc;	

   ioc = (struct spi_ioc_transfer *) arg;

   int fdChk = fd_is_valid(fd);
   printf("fd_is_valid(fd): %d\n", fdChk);

   //if ((file = ::open("/dev/spidev0.0", O_RDWR))<0){
   //             perror("SPI: Can't open device.");
   //             return -1;
   //     }


   unsigned char *tx = (unsigned char *) ioc->tx_buf;
   
   printf("fd: %d\n", fd);
   //printf("file: %d\n", file);
   printf("cmd: %lX\n", cmd);
   printf("spi_ioc_transfer arg\n\n");
   printf("address of tx_buf: %llX\n", ioc->tx_buf);
   printf("address of rx_buf: %llX\n", ioc->rx_buf);
   printf("ioc->len: %d\n", ioc->len);
   printf("ioc->speed_hz: %d\n", ioc->speed_hz);
   printf("ioc->delay_usecs: %d\n", ioc->delay_usecs);
   printf("ioc->bits_per_word: %d\n", ioc->bits_per_word);
   printf("ioc->pad: %d\n", ioc->pad);

   int size_tx_buf = sizeof(ioc->tx_buf);

   printf("sizeof(tx_buf): %d\n", size_tx_buf);

   for (int i = 0; i < size_tx_buf; i++)
      printf("%d\n", tx[i]);

   int status = ioctl(fd, cmd, arg);
   if (status < 0) {
      perror("SPI: Transfer SPI_IOC_MESSAGE Failed");
      return status;
   }
   //tx[0] = 111;

   return 1;
}
}

