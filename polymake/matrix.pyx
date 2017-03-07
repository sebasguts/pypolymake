###############################################################################
#       Copyright (C) 2011-2012 Burcin Erocal <burcin@erocal.org>
#                     2016      Vincent Delecroix <vincent.delecroix@labri.fr>
#  Distributed under the terms of the GNU General Public License (GPL),
#  version 3 or any later version.  The full text of the GPL is available at:
#                  http://www.gnu.org/licenses/
###############################################################################

from libc.stdlib cimport malloc, free
from cygmp.types cimport mpz_t, mpq_t, mpz_srcptr, mpq_srcptr
from cygmp.mpz cimport *
from cygmp.mpq cimport *

from .defs cimport (pm_MatrixRational, pm_Rational,
         pm_MatrixInteger, pm_Integer, pm_VectorInteger,
         mat_rational_get_element, mat_integer_get_element, mat_int_get_element)

from .number cimport Rational, Integer
from .number import get_num_den

from sage_conversion cimport pm_MatrixInt_to_sage, pm_MatrixInteger_to_sage, pm_MatrixRational_to_sage

cdef class MatrixRational:
    def __getitem__(self, elt):
        cdef Py_ssize_t nrows, ncols, i, j
        nrows = self.pm_obj.rows()
        ncols = self.pm_obj.cols()
        i,j = elt
        if not (0 <= i < nrows) or not (0 <= j < ncols):
            raise IndexError("matrix index out of range")

        cdef Rational ans = Rational.__new__(Rational)
        ans.pm_obj.set_mpq_srcptr(mat_rational_get_element(self.pm_obj, i, j).get_rep())
        return ans

    def __repr__(self):
        cdef Py_ssize_t nrows, ncols, i, j
        nrows = self.pm_obj.rows()
        ncols = self.pm_obj.cols()

        rows = [[str(self[i,j]) for j in range(ncols)] for i in range(nrows)]
        col_sizes = [max(len(rows[i][j]) for i in range(nrows)) for j in range(ncols)]

        line_format = "[ " +  \
                " ".join("{{:{width}}}".format(width=t) for t in col_sizes) + \
                      "]"

        return "\n".join(line_format.format(*row) for row in rows)

    def python(self):
        r"""Converts to a list of list of fractions

        >>> import polymake
        >>> c = polymake.cube(3)
        >>> m = c.VERTEX_NORMALS.python()
        >>> m
        [[Fraction(1, 2), Fraction(1, 2), Fraction(1, 2), Fraction(1, 2)],
         [Fraction(1, 2), Fraction(-1, 2), Fraction(1, 2), Fraction(1, 2)],
         [Fraction(1, 2), Fraction(1, 2), Fraction(-1, 2), Fraction(1, 2)],
        ...
         [Fraction(1, 2), Fraction(1, 2), Fraction(-1, 2), Fraction(-1, 2)],
         [Fraction(1, 2), Fraction(-1, 2), Fraction(-1, 2), Fraction(-1, 2)]]
        """
        cdef Py_ssize_t i, j, nrows, ncols
        nrows = self.pm_obj.rows()
        ncols = self.pm_obj.cols()
        return [[self[i,j].python() for j in range(ncols)] for i in range(nrows)]

    def sage(self):
        r"""Converts into a Sage matrix

        >>> import polymake
        >>> c = polymake.cube(3)
        >>> m = c.VERTEX_NORMALS.sage()
        >>> m
        [ 1/2  1/2  1/2  1/2]
        [ 1/2 -1/2  1/2  1/2]
        [ 1/2  1/2 -1/2  1/2]
        ...
        [ 1/2 -1/2 -1/2 -1/2]
        >>> type(m)
        <type 'sage.matrix.matrix_rational_dense.Matrix_rational_dense'>
        """
        return pm_MatrixRational_to_sage(self.pm_obj)

cdef class MatrixInteger:
    def __getitem__(self, elt):
        cdef Py_ssize_t nrows, ncols, i,j
        nrows = self.pm_obj.rows()
        ncols = self.pm_obj.cols()
        i,j = elt
        if not (0 <= i < nrows) or not (0 <= j < ncols):
            raise IndexError("matrix index out of range")

        cdef Integer ans = Integer.__new__(Integer)
        ans.pm_obj.set_mpz_srcptr(mat_integer_get_element(self.pm_obj, i, j).get_rep())
        return ans

    def __repr__(self):
        cdef Py_ssize_t nrows, ncols, i, j
        nrows = self.pm_obj.rows()
        ncols = self.pm_obj.cols()

        rows = [[str(self[i,j]) for j in range(ncols)] for i in range(nrows)]
        col_sizes = [max(len(rows[i][j]) for i in range(nrows)) for j in range(ncols)]

        line_format = "[ " +  \
                " ".join("{{:{width}}}".format(width=t) for t in col_sizes) + \
                      "]"

        return "\n".join(line_format.format(*row) for row in rows)

    def python(self):
        r"""Converts to a list of list of integers

        >>> import polymake
        >>> c = polymake.cube(3)
        >>> m = c.DEGREE_ONE_GENERATORS.python()
        >>> m
        [[1, -1, -1, -1],
         [1, -1, -1, 0],
         [1, -1, -1, 1],
        ...
         [1, 1, 1, 0],
         [1, 1, 1, 1]]
        >>> type(m), type(m[0]), type(m[0][0])
        (<type 'list'>, <type 'list'>, <type 'int'>)
        """
        cdef Py_ssize_t i, j, nrows, ncols
        nrows = self.pm_obj.rows()
        ncols = self.pm_obj.cols()
        return [[self[i,j].python() for j in range(ncols)] for i in range(nrows)]

    def sage(self):
        r"""Converts to a Sage integer matrix

        >>> import polymake
        >>> c = polymake.cube(3)
        >>> m = c.DEGREE_ONE_GENERATORS
        >>> m
        [ 1 -1 -1 -1]
        [ 1 -1 -1 0 ]
        [ 1 -1 -1 1 ]
        ...
        [ 1 1  1  -1]
        [ 1 1  1  0 ]
        [ 1 1  1  1 ]
        >>> s = m.sage()
        >>> s
        27 x 4 dense matrix over Integer Ring
        >>> print s.str()
        [ 1 -1 -1 -1]
        [ 1 -1 -1  0]
        [ 1 -1 -1  1]
        ...
        [ 1  1  1 -1]
        [ 1  1  1  0]
        [ 1  1  1  1]
        >>> type(s)
        <type 'sage.matrix.matrix_integer_dense.Matrix_integer_dense'>
        """
        return pm_MatrixInteger_to_sage(self.pm_obj)

cdef class MatrixInt:
    def __getitem__(self, elt):
        cdef Py_ssize_t nrows, ncols, i,j
        nrows = self.pm_obj.rows()
        ncols = self.pm_obj.cols()
        i,j = elt
        if not (0 <= i < nrows) or not (0 <= j < ncols):
            raise IndexError("matrix index out of range")

        return mat_int_get_element(self.pm_obj, i, j)

    def __repr__(self):
        cdef Py_ssize_t nrows, ncols, i, j
        nrows = self.pm_obj.rows()
        ncols = self.pm_obj.cols()

        rows = [[str(self[i,j]) for j in range(ncols)] for i in range(nrows)]
        col_sizes = [max(len(rows[i][j]) for i in range(nrows)) for j in range(ncols)]

        line_format = "[ " +  \
                " ".join("{{:{width}}}".format(width=t) for t in col_sizes) + \
                      "]"

        return "\n".join(line_format.format(*row) for row in rows)

    def python(self):
        r"""Converts into a list of lists of integers

        >>> import polymake
        >>> c = polymake.cube(3)
        >>> m = c.EDGE_ORIENTATION.python()
        [[0, 4],
         [2, 6],
         [0, 2],
         ...
         [2, 3],
         [6, 7]]
        >>> type(m), type(m[0]), type(m[0][0])
        (<type 'list'>, <type 'list'>, <type 'int'>)
        """
        cdef Py_ssize_t i, j, nrows, ncols
        nrows = self.pm_obj.rows()
        ncols = self.pm_obj.cols()
        return [[self[i,j] for j in range(ncols)] for i in range(nrows)]

    def sage(self):
        r"""Converts into a Sage matrix

        >>> import polymake
        >>> c = polymake.cube(3)
        >>> m = c.EDGE_ORIENTATION
        >>> m.sage()
        [0 4]
        [2 6]
        [0 2]
        ...
        [2 3]
        [6 7]
        >>> type(m.sage())
        <type 'sage.matrix.matrix_integer_dense.Matrix_integer_dense'>
        """
        return pm_MatrixInt_to_sage(self.pm_obj)

def clean_mat(mat):
    r"Return a triple (nr, nc, entries)"
    try:
        nr = mat.nrows()
        nc = mat.ncols()
    except AttributeError:
        if isinstance(mat, (tuple,list)) and mat and \
           all(isinstance(row, (tuple,list)) for row in mat) and mat[0] and \
           all(len(row) == len(mat[0]) for row in mat):
               nr = len(mat)
               nc = len(mat[0])
        else:
            raise ValueError("invalid input {}".format(mat))

    if nr <= 0 or nc <= 0:
        raise ValueError("invalid input {}".format(mat))

    cdef long num, den
    cdef Py_ssize_t i,j
    cdef list clean_mat = []
    cdef list row
    for i in range(nr):
        row = []
        mi = mat[i]
        for j in range(nc):
            row.append(get_num_den(mi[j]))
        clean_mat.append(row)

    return (nr, nc, clean_mat)

cdef pm_MatrixRational* rat_mat_to_pm(int nr, int nc, list mat):
    """
    Create a polymake rational matrix from input so that:

    - there are methods ``nrows``, ``ncols`` giving the number of rows and cols
    - accessing to the elements is done via ``mat[i,j]``
    - given a rational entry we access to numerator and denominator via the
      methods ``.numerator()`` and ``.denominator()``
    """
    # create polymake matrix with dimensions of mat
    cdef pm_MatrixRational* pm_mat = new pm_MatrixRational(nr, nc)

    cdef mpq_t z
    cdef Py_ssize_t i, j
    cdef long num, den

    # clean data
    mpq_init(z)
    for i,row in enumerate(mat):
        for j,elt in enumerate(row):
            mat_rational_get_element(pm_mat[0], i, j).set_long(num, den)
    mpq_clear(z)

    return pm_mat

cdef pm_MatrixInteger* int_mat_to_pm(int nr, int nc, list mat):
    """
    Create a polymake integer matrix from input so that:

    - there are methods ``nrows``, ``ncols`` giving the number of rows and cols
    - accessing to the elements is done via ``mat[i,j]``
    """
    # create polymake matrix with dimensions of mat
    cdef pm_MatrixInteger* pm_mat = new pm_MatrixInteger(nr, nc)

    cdef mpz_t z
    cdef Py_ssize_t i, j

    # clean data
    mpz_init(z)
    for i,row in enumerate(mat):
        for j,elt in enumerate(row):
            mpz_set_si(z, elt)
            mat_integer_get_element(pm_mat[0], i, j).set_mpz_srcptr(z)
    mpz_clear(z)

    return pm_mat

cdef pm_MatrixInt* i_mat_to_pm(int nr, int nc, list mat):
    """
    Create a polymake integer matrix from input so that:

    - there are methods ``nrows``, ``ncols`` giving the number of rows and cols
    - accessing to the elements is done via ``mat[i,j]``
    """
    raise NotImplementedError
