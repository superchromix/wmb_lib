/*
; NAME:
;       RHTgrAABB.c
;
; PURPOSE:
;       
;       This collection of functions provides support for my RHTgrAABB
;		object.
;
;		I am making no effort to document this DLM since it is intended
;		to be used soley by my RHTgrAABB object.
;
;       Thanks to Ronn Kling for leading me into the wonderful
;       world of IDL DLM's with his book "Calling C from IDL - Using DLM's
;       to extend your IDL code".  You can purchase his book from his
;       website: http://www.kilvarock.com
;
;
; AUTHOR:
;
;       Rick Towler
;       School of Aquatic and Fishery Sciences
;       University of Washington
;       Box 355020
;       Seattle, WA 98195-5020
;       rtowler@u.washington.edu
;       www.acoustics.washington.edu
;
;
; CATEGORY:
;
;       Dynamically Loadable Module
;
;
; DEPENDENCIES:
;
;
; CALLING SEQUENCE:
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 03 June 2003.
;
;
; LICENSE
;
;   RHTgrAABB.c  Copyright (C) 2003  Rick Towler
;
;   This program is free software; you can redistribute it and/or
;   modify it under the terms of the GNU General Public License
;   as published by the Free Software Foundation; either version 2
;   of the License, or (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program; if not, write to the Free Software
;   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;   02111-1307, USA.
;
;   A full copy of the GNU General Public License can be found on
;   line at http://www.gnu.org/copyleft/gpl.html#SEC1
;
;-
*/


#include <stdio.h>
#include <stdlib.h>
#include "vec.h"
#include "export.h"

#define STRICT
#define ARRLEN(arr) (sizeof(arr)/sizeof(arr[0]))


IDL_VPTR IDL_CDECL RHTgrAABB_CalcBB(int argc, IDL_VPTR *argv)
{

	short		n,o;
	double		*xCoordConv, *yCoordConv, *zCoordConv, *transIn;
	double		*xRange, *yRange, *zRange, *pBox;
	double		vertex[4], transform[4][4], scale[4][4];
	double		minRange[3], maxRange[3], bBox[3][3];
	IDL_LONG	size[] = {3,3};
	IDL_VPTR	oBox;

	xRange = (double *) argv[0]->value.arr->data;
	yRange = (double *) argv[1]->value.arr->data;
	zRange = (double *) argv[2]->value.arr->data;
	xCoordConv = (double *) argv[3]->value.arr->data;
	yCoordConv = (double *) argv[4]->value.arr->data;
	zCoordConv = (double *) argv[5]->value.arr->data;
	transIn = (double *) argv[6]->value.arr->data;

	for (n = 0; n < 4; ++n) {
		for (o = 0; o < 4; ++o) 
			transform[n][o] = transIn[n*4+o];
	}

	pBox = (double *) IDL_MakeTempArray((int)IDL_TYP_DOUBLE, 2, size,
		IDL_ARR_INI_NOP, &oBox);

	IDENTMAT4(scale);
	scale[0][0] = xCoordConv[1];
	scale[0][3] = xCoordConv[0];
	scale[1][1] = yCoordConv[1];
	scale[1][3] = yCoordConv[0];
	scale[2][2] = zCoordConv[1];
	scale[2][3] = zCoordConv[0];

	MXM4d(transform, scale, transform);

	vertex[0] = xRange[0];
	vertex[1] = yRange[0];
	vertex[2] = zRange[0];
	vertex[3] = 1.;
	
	MXV4d(vertex,transform,vertex);

	if (vertex[3] != 0 && vertex[3] != 1) {
		vertex[0] = vertex[0] / vertex[3];
		vertex[1] = vertex[1] / vertex[3];
		vertex[2] = vertex[2] / vertex[3];
	}

	minRange[0] = vertex[0];
	minRange[1] = vertex[1];
	minRange[2] = vertex[2];
	maxRange[0] = vertex[0];
	maxRange[1] = vertex[1];
	maxRange[2] = vertex[2];

	for (n = 1; n<8; n++) {

		vertex[0] = xRange[n & 1];
		vertex[1] = yRange[(n / 2) & 1];
		vertex[2] = zRange[(n / 4) & 1];
		vertex[3] = 1.;

		MXV4d(vertex,transform,vertex);

		if (vertex[3] != 0 && vertex[3] != 1) {
			vertex[0] = vertex[0] / vertex[3];
			vertex[1] = vertex[1] / vertex[3];
			vertex[2] = vertex[2] / vertex[3];
		}

		if (minRange[0] > vertex[0]) minRange[0] = vertex[0];
		if (minRange[1] > vertex[1]) minRange[1] = vertex[1];
		if (minRange[2] > vertex[2]) minRange[2] = vertex[2];
		if (maxRange[0] < vertex[0]) maxRange[0] = vertex[0];
		if (maxRange[1] < vertex[1]) maxRange[1] = vertex[1];
		if (maxRange[2] < vertex[2]) maxRange[2] = vertex[2];

	}

	pBox[0] = minRange[0];
	pBox[1] = minRange[1];
	pBox[2] = minRange[2];
	pBox[3] = maxRange[0];
	pBox[4] = maxRange[1];
	pBox[5] = maxRange[2];
	pBox[6] = 1.;
	pBox[7] = 1.;
	pBox[8] = 1.;

	return oBox;

}


int IDL_Load(void)
{

	static IDL_SYSFUN_DEF2 function_addr[] = {
		{(IDL_SYSRTN_GENERIC) RHTgrAABB_CalcBB, "RHTGRAABB_CALCBB", 7, 7, 0, 0},
	};

	return IDL_SysRtnAdd(function_addr, TRUE, ARRLEN(function_addr));
}
