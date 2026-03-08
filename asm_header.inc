%ifdef __APPLE__
    %define SYM(x) _ %+ x
%else
    %define SYM(x) x
%endif