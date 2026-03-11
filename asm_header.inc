%ifdef __APPLE__
    %define SYM(x) _ %+ x
    %define CALL(x) call x
%else
    %define SYM(x) x
    %define CALL(x) call x WRT ..plt
%endif
