#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/mman.h>

#define MAXSIZE (COUNTER_RESET - MATCH_COUNT_RESULT + MEMORY_SIZE)
#define MEMORY_SIZE (PASS_COUNT_RESULT - MATCH_COUNT_RESULT)
#define MATCH_COUNT_RESULT 0x80000000
#define PASS_COUNT_RESULT 0x80010000
#define FILTER_COUNT_RESULT 0x80020000
#define COUNTER_RESET 0x80030000

int main()
{
    int fd;

    volatile void *memory_base;

    volatile unsigned int *match_count_result;
    volatile unsigned int *pass_count_result;
    volatile unsigned int *filter_count_result;
    volatile unsigned char *counter_reset;

    unsigned int count = 0;
    float throughput = 0.0f;

    printf("open memory\n");
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    
    if(fd == -1)
    {
        printf("memory open fail!\n");
        return 0;
    }

    memory_base = mmap(0,
                        MAXSIZE,
                        PROT_READ|PROT_WRITE,
                        MAP_SHARED,
                        fd,
                        MATCH_COUNT_RESULT);

    if(memory_base == NULL)
    {
        printf("memory mapping fail!\n");
        return 0;
    }

    match_count_result = (volatile unsigned int*)(memory_base + MATCH_COUNT_RESULT - MATCH_COUNT_RESULT);
    pass_count_result = (volatile unsigned int*)(memory_base + PASS_COUNT_RESULT - MATCH_COUNT_RESULT);
    filter_count_result = (volatile unsigned int*)(memory_base + FILTER_COUNT_RESULT - MATCH_COUNT_RESULT);
    counter_reset = (volatile unsigned char*)(memory_base + COUNTER_RESET - MATCH_COUNT_RESULT);

    printf("memory mapping success!\n");

    while(1)
    {
        *counter_reset = 1;
        *counter_reset = 0;

        usleep(1000000);

        printf("string matchers are ongoing!\n");
        printf("gpio matcher\n");
        printf("packet = 512bit\n\n");
        printf("runtime\t: %08d sec\n", count++);
        printf("checked\t: %08d packet/sec\n", *pass_count_result);
        printf("filtered: %08d packet/sec\n", *filter_count_result);
        printf("match\t: %08d packet/sec\n", *match_count_result);

        throughput = (float)*pass_count_result * 512 / 1024 / 1024;
        printf("speed\t: %.02f Mbps\n\n\n", throughput);
    }
}