#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <time.h>

#define INSTRUCTION_MEMORY 0x82000000
#define DATA_MEMORY 0x80000000
#define MAX_SIZE 0x2100000

int main()
{
    FILE* file_fp;
    int fd;
    volatile void *memory_base;
    volatile unsigned int* instruction_mem;
    volatile unsigned int* data_mem;

    unsigned int data;
    unsigned int count = 0;
    float throughput = 0.0f;
    int result;

    printf("file_open\n");
    file_fp = fopen("real_RISC-V_code_bin.txt", "r");
    
    if(file_fp == NULL) {
        printf("file_open_fail!!\n");
        return 0;
    }
        
    printf("open memory\n");
    fd = open("/dev/mem", O_RDWR | O_SYNC);

    if(fd == -1)
    {
        printf("memory open fail!\n");
        return 0;
    }

    data_mem = (volatile unsigned int*)mmap(0,
                        0x10000,
                        PROT_READ|PROT_WRITE,
                        MAP_SHARED,
                        fd,
                        DATA_MEMORY);

    instruction_mem = (volatile unsigned int*)mmap(0,
                        0x10000,
                        PROT_READ|PROT_WRITE,
                        MAP_SHARED,
                        fd,
                        INSTRUCTION_MEMORY);

    printf("memory mapping success!\n");

    while(1)
    {
        result = fscanf(file_fp, "%x\n", &data);

        if(result == EOF)
            break;

        *(instruction_mem + count) = (unsigned int)data;
        
        count++;
    }

    *(data_mem + 0x203) = 100;

    printf("file read success!\n");

    fclose(file_fp);
    

    *(data_mem + 0x205) = 0;

    usleep(1000000);

    *(data_mem + 0x205) = 1;

    printf("core start!\n");

    while(1)
    {
        usleep(1000000);

        printf("string matchers are ongoing!\n");
        printf("risc matcher\n");
        printf("packet = 512bit\n\n");
        printf("runtime\t: %08d sec\n", count++);
        printf("checked\t: %08d packet/sec\n", *(data_mem + 0x201));
        printf("filtered: %08d packet/sec\n", *(data_mem + 0x202));
        printf("match\t: %08d packet/sec\n", *(data_mem + 0x200));

        throughput = (float)*(data_mem + 0x201) * 512 / 1024 / 1024;
        printf("speed\t: %.02f Mbps\n\n\n", throughput);
    }

    return 0;
}