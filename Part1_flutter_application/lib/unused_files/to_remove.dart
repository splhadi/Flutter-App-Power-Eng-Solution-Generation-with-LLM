
String to_remove_item="""
constant:
ep=8.85*10^(-12)
formulas:
V=I*R
A=pi*(r)^(2)
R=(rho*l)/A
L=2*10^(-7)ln(GMD_b/GMR_b)
X_l=2*pi*f*L

GMD_b=D,D1=D2=D3
GMD_b=(D1*D2*D3)^(1/3),D1!=D2!=D3

GMR_b=(GMR_cond*d)^(1/n),n=2
GMR_b=(GMR_cond*d^2)^(1/n),n=3
GMR_b=1.09*(GMR_cond*d)^(1/n),n=4

C=2*pi*ep/ln(GMD_b/r_b)
r_b=r,n=1
r_b=(r*d)^(1/n),n=2
r_b=(r*d^2)^(1/n),n=3
r_b=1.09*(r*d^3)^(1/n),n=4
X_c=1/(2*pi*f*C)

Z=R+i*X_l
Y=2*pi*C*i

matrix_representation:
V_s=A_m*V_r+B_m*I_r
I_s=C_m*V_r+D_m*I_r

A_m=1,l=s
B_m=Z,l=s
C_m=0,l=s
D_m=1,l=s

A_m=Z*Y/2+1,l=pi
B_m=Z,l=pi
C_m=Y*((Z*Y)/4+1),l=pi
D_m=(Z*Y)/2+1,l=pi

A_m=Z*Y/2+1,l=T
B_m=Z*((Z*Y)/4+1),l=T
C_m=Y,l=T
D_m=(Z*Y)/2+1,l=T

"""
  ;
