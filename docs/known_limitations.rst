Known limitations
=================

* **Local minima**: To avoid local minima, you can try to increase the number of starting point ``n_starts``.
* **Stiff equations**: For some parameter sets, the model ODEs may be very stiff. The implicit Euler scheme used by `SBML2Julia` may encounter numerical errors. You can try increasing the number of discretization time steps by increasing ``t_ratio`` or reducing the parameter search window in the `Petab` parameter table.