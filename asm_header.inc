%ifdef __APPLE__
    %define SYM(x) _ %+ x
    %define CALL(x) call x
	%define SYS_WRITE 0x2000004
%else
    %define SYM(x) x
    %define CALL(x) call x WRT ..plt
	%define SYS_WRITE 1
%endif
