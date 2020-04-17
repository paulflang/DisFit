using JuMP
using Ipopt
using CSV

fc = 2 # Setting parameter search span
t_ratio = 2 # Setting number of ODE discretisation steps

# Data
data_path = "/media/sf_DPhil_Project/Project07_Parameter Fitting/df_software/DisFit/tests/fixtures/G2M_copasi.csv"
df = CSV.read(data_path)
t_exp = Vector(df[!, :t]) # set of simulation times.)
t_sim = range(0, stop=t_exp[end], length=t_exp[end]*t_ratio+1)

# create JuMP model object")
# m = Model(with_optimizer(KNITRO.Optimizer, ms_enable=1, ms_maxtime_real=10))
m = Model(with_optimizer(Ipopt.Optimizer))

# Model parameters
println("Defining parameters ...")
@variable(m, 0.1/fc <= kPhEnsa <= 0.1*fc)
@variable(m, 0.05/fc <= kDpEnsa <= 0.05*fc)
@variable(m, 1.0/fc <= kPhGw <= 1.0*fc)
@variable(m, 0.25/fc <= kDpGw1 <= 0.25*fc)
@variable(m, 10.0/fc <= kDpGw2 <= 10.0*fc)
@variable(m, 0.01/fc <= kWee1 <= 0.01*fc)
@variable(m, 0.99/fc <= kWee2 <= 0.99*fc)
@variable(m, 1.0/fc <= kPhWee <= 1.0*fc)
@variable(m, 10.0/fc <= kDpWee <= 10.0*fc)
@variable(m, 0.1/fc <= kCdc25_1 <= 0.1*fc)
@variable(m, 0.9/fc <= kCdc25_2 <= 0.9*fc)
@variable(m, 1.0/fc <= kPhCdc25 <= 1.0*fc)
@variable(m, 10.0/fc <= kDpCdc25 <= 10.0*fc)
@variable(m, 0.0068/fc <= kDipEB55 <= 0.0068*fc)
@variable(m, 57.0/fc <= kAspEB55 <= 57.0*fc)

# Model states
println("Defining states ...")
@variable(m, 0 <= Cb[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= pCb[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= Wee[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= pWee[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= Cdc25[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= pCdc25[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= Gw[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= pGw[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= Ensa[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= pEnsa[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= pEB55[k in 1:length(t_sim)] <= 1)
@variable(m, 0 <= B55[k in 1:length(t_sim)] <= 1)

# Model ODEs
println("Defining ODEs ...")
@NLconstraint(m, [k in 1:length(t_sim)-1],
    Cb[k+1] == Cb[k] + ( -1.0*(kWee2 * Cb[k+1] * Wee[k+1]) -1.0*(kWee1 * Cb[k+1]) +1.0*(kCdc25_1 * pCb[k+1]) +1.0*(kCdc25_2 * pCb[k+1] * pCdc25[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    pCb[k+1] == pCb[k] + ( +1.0*(kWee2 * Cb[k+1] * Wee[k+1]) +1.0*(kWee1 * Cb[k+1]) -1.0*(kCdc25_1 * pCb[k+1]) -1.0*(kCdc25_2 * pCb[k+1] * pCdc25[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    Wee[k+1] == Wee[k] + ( -1.0*(kPhWee * Cb[k+1] * Wee[k+1]) +1.0*(kDpWee * pWee[k+1] * B55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    pWee[k+1] == pWee[k] + ( +1.0*(kPhWee * Cb[k+1] * Wee[k+1]) -1.0*(kDpWee * pWee[k+1] * B55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    Cdc25[k+1] == Cdc25[k] + ( -1.0*(kPhCdc25 * Cb[k+1] * Cdc25[k+1]) +1.0*(kDpCdc25 * pCdc25[k+1] * B55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    pCdc25[k+1] == pCdc25[k] + ( +1.0*(kPhCdc25 * Cb[k+1] * Cdc25[k+1]) -1.0*(kDpCdc25 * pCdc25[k+1] * B55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    Gw[k+1] == Gw[k] + ( -1.0*(kPhGw * Gw[k+1] * Cb[k+1]) +1.0*(kDpGw1 * pGw[k+1]) +1.0*(kDpGw2 * pGw[k+1] * B55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    pGw[k+1] == pGw[k] + ( +1.0*(kPhGw * Gw[k+1] * Cb[k+1]) -1.0*(kDpGw1 * pGw[k+1]) -1.0*(kDpGw2 * pGw[k+1] * B55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    Ensa[k+1] == Ensa[k] + ( -1.0*(kPhEnsa * Ensa[k+1] * pGw[k+1]) +1.0*(kDpEnsa * pEB55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    pEnsa[k+1] == pEnsa[k] + ( +1.0*(kPhEnsa * Ensa[k+1] * pGw[k+1]) -1.0*(kAspEB55 * B55[k+1] * pEnsa[k+1]) +1.0*(kDipEB55 * pEB55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    pEB55[k+1] == pEB55[k] + ( +1.0*(kAspEB55 * B55[k+1] * pEnsa[k+1]) -1.0*(kDipEB55 * pEB55[k+1]) -1.0*(kDpEnsa * pEB55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )
@NLconstraint(m, [k in 1:length(t_sim)-1],
    B55[k+1] == B55[k] + ( -1.0*(kAspEB55 * B55[k+1] * pEnsa[k+1]) +1.0*(kDipEB55 * pEB55[k+1]) +1.0*(kDpEnsa * pEB55[k+1]) ) * ( t_sim[k+1] - t_sim[k] ) )

# Define objective
println("Defining objective ...")
@NLobjective(m, Min,sum((Cb[(k-1)*t_ratio+1]-df[k, :Cb])^2 for k in 1:length(t_exp))
    + sum((pCb[(k-1)*t_ratio+1]-df[k, :pCb])^2 for k in 1:length(t_exp))
    + sum((Wee[(k-1)*t_ratio+1]-df[k, :Wee])^2 for k in 1:length(t_exp))
    + sum((pWee[(k-1)*t_ratio+1]-df[k, :pWee])^2 for k in 1:length(t_exp))
    + sum((Cdc25[(k-1)*t_ratio+1]-df[k, :Cdc25])^2 for k in 1:length(t_exp))
    + sum((pCdc25[(k-1)*t_ratio+1]-df[k, :pCdc25])^2 for k in 1:length(t_exp))
    + sum((Gw[(k-1)*t_ratio+1]-df[k, :Gw])^2 for k in 1:length(t_exp))
    + sum((pGw[(k-1)*t_ratio+1]-df[k, :pGw])^2 for k in 1:length(t_exp))
    + sum((Ensa[(k-1)*t_ratio+1]-df[k, :Ensa])^2 for k in 1:length(t_exp))
    + sum((pEnsa[(k-1)*t_ratio+1]-df[k, :pEnsa])^2 for k in 1:length(t_exp))
    + sum((pEB55[(k-1)*t_ratio+1]-df[k, :pEB55])^2 for k in 1:length(t_exp))
    + sum((B55[(k-1)*t_ratio+1]-df[k, :B55])^2 for k in 1:length(t_exp))
    )

println("Optimizing...")
optimize!(m)


