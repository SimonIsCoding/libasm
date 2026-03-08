#Variables
NAME	= libasm.a
COMP	= gcc
FLAGS	= 
SRCS	= 	ft_strlen.s \
			ft_strcpy.s \
			ft_strcmp
OBJS	= $(SRCS:.s=.o)
EXEC	= $(SRCS:.s=)
RM 		= rm -rf 
ifeq ($(shell uname -m), arm64)
    COMP += -ld_classic --target=x86_64-apple-darwin
endif

#-f macho64

#Rules
all:	Makefile $(OBJS)
		$(COMP) $(FLAGS) -o $(NAME)

$(NAME):
	$(COMP) 

clean:
	$(RM) $(OBJS) $(EXEC)

fclean: clean
	$(RM) $(NAME)

re: fclean all

.PHONY: all clean fclean re