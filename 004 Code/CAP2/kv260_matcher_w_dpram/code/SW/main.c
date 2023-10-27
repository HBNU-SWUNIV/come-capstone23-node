#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <time.h>

#define DATA_MEMORY 0x80000000
#define MAX_SIZE 0x10000

#define ADDR_RESET 0x01
#define ADDR_MATCH 0x02
#define ADDR_PASS 0x03
#define ADDR_FILTER 0x04

int main()
{
    int fd;
    volatile unsigned int* data_mem;

    unsigned int data;
    int count = 0;
    float throughput = 0.0f;

    printf("open memory\n");
    fd = open("/dev/mem", O_RDWR | O_SYNC);

    if(fd == -1)
    {
        printf("memory open fail!\n");
        return 0;
    }

    data_mem = (volatile unsigned int*)mmap(0,
                        MAX_SIZE,
                        PROT_READ|PROT_WRITE,
                        MAP_SHARED,
                        fd,
                        DATA_MEMORY);

    printf("memory mapping success!\n");


    printf("matching start!\n");

    while(1)
    {
        *(data_mem + ADDR_RESET) = 1;
        while(*(data_mem + ADDR_MATCH));
        *(data_mem + ADDR_RESET) = 0;

        usleep(1000000);

        printf("string matchers are ongoing!\n");
        printf("32 matcher\n");
        printf("packet = 512bit\n\n");
        printf("runtime\t: %08d sec\n", count++);
        printf("checked\t: %08d packet/sec\n", *(data_mem + ADDR_PASS));
        printf("filtered: %08d packet/sec\n", *(data_mem + ADDR_FILTER));
        printf("match\t: %08d packet/sec\n", *(data_mem + ADDR_MATCH));

        throughput = (float)(*(data_mem + ADDR_PASS)) * 512 / 1024 / 1024;
        printf("speed\t: %.02f Mbps\n\n\n", throughput);
    }

    return 0;
}