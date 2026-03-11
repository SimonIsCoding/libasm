#Variables
NAME	= libasm.a
OS		= $(shell uname -s)
AS		= nasm
AR		= ar
ARFLAGS	= rcs
ASFLAGS	= -f $(FORMAT)
SRCS	= 	ft_strlen.s \
			ft_strcpy.s \
			ft_strcmp.s
OBJS	= $(SRCS:.s=.o)
EXEC	= $(SRCS:.s=)
RM 		= rm -rf

ifeq ($(OS), Darwin)
	FORMAT = macho64
	ASFLAGS += -D __APPLE__
	CC_CMD = arch -x86_64 cc
else
	FORMAT = elf64
	CC_CMD = cc
endif

#Rules
all:	$(NAME)

$(NAME): Makefile $(OBJS)
	$(AR) $(ARFLAGS) $(NAME) $(OBJS)

%.o: %.s
	$(AS) $(ASFLAGS) -D PREFIX=$(PREFIX) $< -o $@

main.o: main.s
	$(AS) $(ASFLAGS) main.s -o main.o

test: $(NAME) main.o
	$(CC_CMD) main.o $(NAME) -o test_libasm
	./test_libasm

clean:
	$(RM) $(OBJS) $(EXEC) main.o test_libasm

fclean: clean
	$(RM) $(NAME)

re: fclean all

.PHONY: all clean fclean re