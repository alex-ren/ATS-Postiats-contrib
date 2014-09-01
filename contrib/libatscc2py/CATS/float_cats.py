######
#
# HX-2014-08:
# for Python code translated from ATS
#
######

###### beg of [float_cats.py] ######

############################################
#
def ats2pypre_double2int(x): return int(x)
def ats2pypre_int_of_double(x): return int(x)
#
def ats2pypre_int2double(x): return float(x)
def ats2pypre_double_of_int(x): return float(x)
#
############################################
#
def ats2pypre_add_double_double(x, y): return (x + y)
def ats2pypre_sub_double_double(x, y): return (x - y)
def ats2pypre_mul_double_double(x, y): return (x * y)
def ats2pypre_div_double_double(x, y): return (x // y)
#
############################################
#
def ats2pypre_lt_double_double(x, y): return (x < y)
def ats2pypre_lte_double_double(x, y): return (x <= y)
def ats2pypre_gt_double_double(x, y): return (x > y)
def ats2pypre_gte_double_double(x, y): return (x >= y)
#
def ats2pypre_eq_double_double(x, y): return (x == y)
def ats2pypre_neq_double_double(x, y): return (x != y)
#
############################################

###### end of [float_cats.py] ######