#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

void setup();
void loop();
int main()
{
    setup();
    for(;;)
    {
        loop();
    }
    return 0;
}

void setup()
{

}
void loop()
{

}

