/* glpenv05.c (dynamic memory allocation) */

/***********************************************************************
*  This code is part of GLPK (GNU Linear Programming Kit).
*
*  Copyright (C) 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008,
*  2009, 2010, 2011, 2013 Andrew Makhorin, Department for Applied
*  Informatics, Moscow Aviation Institute, Moscow, Russia. All rights
*  reserved. E-mail: <mao@gnu.org>.
*
*  GLPK is free software: you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*  GLPK is distributed in the hope that it will be useful, but WITHOUT
*  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
*  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
*  License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with GLPK. If not, see <http://www.gnu.org/licenses/>.
***********************************************************************/

#include "glpk.h"
#include "glpenv.h"

/***********************************************************************
*  dma - dynamic memory allocation (basic routine)
*
*  This routine performs dynamic memory allocation. It is similar to
*  the standard realloc function, however, it provides every allocated
*  memory block with a descriptor, which is used for sanity checks on
*  reallocating/freeing previously allocated memory blocks as well as
*  for book-keeping the memory usage statistics. */

static void *dma(const char *func, void *ptr, size_t size)
{     ENV *env = get_env_ptr();
      MEM *mem;
      if (ptr == NULL)
      {  /* new memory block will be allocated */
         mem = NULL;
      }
      else
      {  /* allocated memory block will be reallocated or freed */
         /* get pointer to the block descriptor */
         mem = (MEM *)((char *)ptr - MEM_DESC_SIZE);
         /* make sure that the block descriptor is valid */
         if (mem->magic != MEM_MAGIC)
            xerror("%s: ptr = %p; invalid pointer\n", func, ptr);
         /* remove the block from the linked list */
         mem->magic = 0;
         if (mem->prev == NULL)
            env->mem_ptr = mem->next;
         else
            mem->prev->next = mem->next;
         if (mem->next == NULL)
            ;
         else
            mem->next->prev = mem->prev;
         /* decrease usage counts */
         if (!(env->mem_count >= 1 && env->mem_total >= mem->size))
            xerror("%s: memory allocation error\n", func);
         env->mem_count--;
         env->mem_total -= mem->size;
         if (size == 0)
         {  /* free the memory block */
            free(mem);
            return NULL;
         }
      }
      /* allocate/reallocate memory block */
      if (size > SIZE_T_MAX - MEM_DESC_SIZE)
         xerror("%s: size too large\n", func);
      size += MEM_DESC_SIZE;
      if (size > env->mem_limit - env->mem_total)
         xerror("%s: memory allocation limit exceeded\n", func);
      if (env->mem_count == INT_MAX)
         xerror("%s: too many memory blocks allocated\n", func);
      mem = (mem == NULL ? malloc(size) : realloc(mem, size));
      if (mem == NULL)
         xerror("%s: no memory available\n", func);
      /* setup the block descriptor */
      mem->magic = MEM_MAGIC;
      mem->size = size;
      mem->prev = NULL;
      mem->next = env->mem_ptr;
      /* add the block to the beginning of the linked list */
      if (mem->next != NULL)
         mem->next->prev = mem;
      env->mem_ptr = mem;
      /* increase usage counts */
      env->mem_count++;
      if (env->mem_cpeak < env->mem_count)
         env->mem_cpeak = env->mem_count;
      env->mem_total += size;
      if (env->mem_tpeak < env->mem_total)
         env->mem_tpeak = env->mem_total;
      return (char *)mem + MEM_DESC_SIZE;
}

/***********************************************************************
*  NAME
*
*  glp_malloc - allocate memory block
*
*  SYNOPSIS
*
*  void *glp_malloc(int size);
*
*  DESCRIPTION
*
*  The routine glp_malloc allocates a memory block of size bytes long.
*
*  Note that being allocated the memory block contains arbitrary data
*  (not binary zeros).
*
*  RETURNS
*
*  The routine glp_malloc returns a pointer to the allocated block.
*  To free this block the routine glp_free (not free!) must be used. */

void *glp_malloc(int size)
{     if (size < 1)
         xerror("glp_malloc: size = %d; invalid parameter\n", size);
      return dma("glp_malloc", NULL, size);
}

/***********************************************************************
*  NAME
*
*  glp_calloc - allocate memory block
*
*  SYNOPSIS
*
*  void *glp_calloc(int n, int size);
*
*  DESCRIPTION
*
*  The routine glp_calloc allocates a memory block of n * size bytes
*  long.
*
*  Note that being allocated the memory block contains arbitrary data
*  (not binary zeros).
*
*  RETURNS
*
*  The routine glp_calloc returns a pointer to the allocated block.
*  To free this block the routine glp_free (not free!) must be used. */

void *glp_calloc(int n, int size)
{     if (n < 1)
         xerror("glp_calloc: n = %d; invalid parameter\n", n);
      if (size < 1)
         xerror("glp_calloc: size = %d; invalid parameter\n", size);
      if ((size_t)n > SIZE_T_MAX / (size_t)size)
         xerror("glp_calloc: n = %d, size = %d; array too large\n",
            n, size);
      return dma("glp_calloc", NULL, (size_t)n * (size_t)size);
}

/**********************************************************************/

void *glp_realloc(void *ptr, int n, int size)
{     /* reallocate memory block */
      if (ptr == NULL)
         xerror("glp_realloc: ptr = %p; invalid pointer\n", ptr);
      if (n < 1)
         xerror("glp_realloc: n = %d; invalid parameter\n", n);
      if (size < 1)
         xerror("glp_realloc: size = %d; invalid parameter\n", size);
      if ((size_t)n > SIZE_T_MAX / (size_t)size)
         xerror("glp_realloc: n = %d, size = %d; array too large\n",
            n, size);
      return dma("glp_realloc", ptr, (size_t)n * (size_t)size);
}

/***********************************************************************
*  NAME
*
*  glp_free - free memory block
*
*  SYNOPSIS
*
*  void glp_free(void *ptr);
*
*  DESCRIPTION
*
*  The routine glp_free frees a memory block pointed to by ptr, which
*  was previuosly allocated by the routine glp_malloc or glp_calloc. */

void glp_free(void *ptr)
{     if (ptr == NULL)
         xerror("glp_free: ptr = %p; invalid pointer\n", ptr);
      dma("glp_free", ptr, 0);
      return;
}

/***********************************************************************
*  NAME
*
*  glp_mem_limit - set memory usage limit
*
*  SYNOPSIS
*
*  void glp_mem_limit(int limit);
*
*  DESCRIPTION
*
*  The routine glp_mem_limit limits the amount of memory available for
*  dynamic allocation (in GLPK routines) to limit megabytes. */

void glp_mem_limit(int limit)
{     ENV *env = get_env_ptr();
      if (limit < 1)
         xerror("glp_mem_limit: limit = %d; invalid parameter\n",
            limit);
      if ((size_t)limit <= (SIZE_T_MAX >> 20))
         env->mem_limit = (size_t)limit << 20;
      else
         env->mem_limit = SIZE_T_MAX;
      return;
}

/***********************************************************************
*  NAME
*
*  glp_mem_usage - get memory usage information
*
*  SYNOPSIS
*
*  void glp_mem_usage(int *count, int *cpeak, size_t *total,
*     size_t *tpeak);
*
*  DESCRIPTION
*
*  The routine glp_mem_usage reports some information about utilization
*  of the memory by GLPK routines. Information is stored to locations
*  specified by corresponding parameters (see below). Any parameter can
*  be specified as NULL, in which case its value is not stored.
*
*  *count is the number of the memory blocks currently allocated by the
*  routines glp_malloc and glp_calloc (one call to glp_malloc or
*  glp_calloc results in allocating one memory block).
*
*  *cpeak is the peak value of *count reached since the initialization
*  of the GLPK library environment.
*
*  *total is the total amount, in bytes, of the memory blocks currently
*  allocated by the routines glp_malloc and glp_calloc.
*
*  *tpeak is the peak value of *total reached since the initialization
*  of the GLPK library envirionment. */

void glp_mem_usage(int *count, int *cpeak, size_t *total,
      size_t *tpeak)
{     ENV *env = get_env_ptr();
      if (count != NULL)
         *count = env->mem_count;
      if (cpeak != NULL)
         *cpeak = env->mem_cpeak;
      if (total != NULL)
         *total = env->mem_total;
      if (tpeak != NULL)
         *tpeak = env->mem_tpeak;
      return;
}

/* eof */
