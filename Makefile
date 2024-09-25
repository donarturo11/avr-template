PROJECT_NAME = project_template
CONFIG ?= attiny85
DEFINITIONS =
include config/$(CONFIG)/Makefile.mk
FIRMWARENAME = $(PROJECT_NAME)-$(MCU)
CC = avr-gcc
OBJCOPY = avr-objcopy
DUDE = avrdude
PROGRAMMER ?= siprog
DUDEFLAGS = -v -p $(MCU) -c $(PROGRAMMER)
ifeq ($(PROGRAMMER), siprog)
DUDEFLAGS += -b 19200
#DUDEFLAGS += -P /dev/ttyS0
endif

CFLAGS = -Wall -Os -I. -mmcu=$(MCU) -DF_CPU=$(F_CPU)
CFLAGS += -I./config/$(CONFIG)/
OBJFLAGS = -j .text -j .data  
OBJECTS = main.o
#OBJECTS += 

all: $(FIRMWARENAME).hex $(FIRMWARENAME).bin $(FIRMWARENAME).asm

%.hex: %.elf
	$(OBJCOPY) $(OBJFLAGS) -O ihex $< $@

%.bin: %.elf
	$(OBJCOPY) $(OBJFLAGS) -O binary $< $@

$(FIRMWARENAME).asm: $(FIRMWARENAME).hex
	avr-objdump --no-show-raw-insn -m$(AVRARCH) -D -S $(FIRMWARENAME).hex > $@

$(FIRMWARENAME).elf: $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^
	avr-size --format=avr --mcu=$(DEVICE) $(FIRMWARENAME).elf

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.S
	$(CC) $(CFLAGS) -x assembler-with-cpp -c -o $@ $<

fuse:
	$(DUDE) $(DUDEFLAGS) -e $(FUSES)

flash:
	$(DUDE) $(DUDEFLAGS) -Uflash:w:$(FIRMWARENAME).hex:i

simulavr:
	simulavr -d $(MCU) -o tracelist-$(MCU).txt
	@echo -e "\nPress Ctrl+C to abort\n"
	simulavr -d $(MCU) -F $(F_CPU) -c vcd:tracelist-$(MCU).txt:trace-$(MCU).vcd -f $(FIRMWARENAME).elf

clean:
	$(RM) *.o *.elf *.hex *.asm *.bin tracelist*.txt *.vcd
