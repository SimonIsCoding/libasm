#Variables
NAME	= libasm.a
COMP	= gcc
FLAGS	= 
SRCS	= ft_strlen.s
OBJS	= $(SCRS:.c=.o)
RM 		= rm -rf 
ifeq ($(shell uname -m), arm64)
    COMP += -ld_classic --target=x86_64-apple-darwin
endif

-f macho64

#Rules
all:	Makefile $(OBJS)
		$(COMP) $(FLAGS) -o $(NAME)

$(NAME):