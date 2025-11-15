

== Euclidean GCD
#set math.equation(numbering: none)

Given a sequence of matrices $A_(n_1 times n_2),A_(n_2 times n_3),..,A_(n_(q-1) times q_i)$, Compute the minimum number of scalar multiplication required to multiply all of them.  
The algorithm takes in vector $d = (n_1,..,n_q)$ and returns an integer.

Formal definition: $"num_mul"(d) := T_d (0,|d|-2)$ where

$
  T_d (i, j) = min_{k|i<=k<j} T_d (i,k)+T_d (k+1,j)+d(i) dot d(j+1) dot d(k+1)
$  
This is a classic dynamic programming algorithm where we build up by solving subproblems. $T_d$ is a matrix whose (i,j)th represents the subproblem instance (n_i,...,n_j+1)

Examples:
- $"num_mul"(10, 20, 30, 40, 50) -> 38000 $
- $"num_mul"(13, 5, 89, 3, 34) -> 2856$

*As mapcode:*

_primitives_: `mod`($mod$) is strict. i.e operation on $bot$ is undefined.

$
  I = "vec"[NN] quad quad quad X & = NN times NN -> NN_bot quad quad quad
  A = NN \
    rho(d) & = {(i,j) -> bot | i,j in NN} \
        F_d (x) & = cases(
                  0 & "if " i = j,
                  min { x(i,k)+ x(k+1,j)+d(i) dot d(j+1) dot d(k+1) |i<=k<j} & "else"
                ) \
        pi_d (x) & = x(0,|d|-2)
$



