/*
; NAME:
;       RHTgrCamera.c
;
; PURPOSE:
;       
;       This collection of functions provides support for my RHTgrCamera
;		object.
;
;		I am making no effort to document this DLM since it is intended
;		to be used soley by my RHTgrCamera object.
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
;       Written by: Rick Towler, 15 November 2002.
;
;
; LICENSE
;
;   RHTgrCamera.c  Copyright (C) 2002-2003  Rick Towler
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
#include <math.h>
#include "vec.h"
#include "export.h"

#define STRICT
#define ARRLEN(arr) (sizeof(arr)/sizeof(arr[0]))
#define SQR(x) ((x)*(x))

const int	faceConn[6][3]={{0,1,2},{4,7,6},{7,4,0},{6,2,1},{0,4,5},{2,6,7}};


double* get_polygon_normal(double normal[3], int nverts, const double verts[][3])
{

	/*  
		Adapted from: D. Hatch and D. Green. Fast Polygon-Cube Intersection Testing. In
					  Alan W. Paeth, editor, Graphics Gems V, pages 375-379. AP Professional,
					  Boston, 1995.
	*/

    int i;
    double tothis[3], toprev[3], cross[3];

    ZEROVEC3(normal);
    VMV3(toprev, verts[1], verts[0]);
    for (i = 2; i <= nverts-1; ++i) {
		VMV3(tothis, verts[i], verts[0]);
		VXV3(cross, toprev, tothis);
		VPV3(normal, normal, cross);
		SET3(toprev, tothis);
    }
    return normal;
}


//  RHTgrCamera_Transform
IDL_VPTR IDL_CDECL RHTgrCamera_Transform(int argc, IDL_VPTR *argv)
{
	/*

		transform = RHTgrCamera_Transform(rotation, location, viewZ)

	*/

	int			n,o;
	double		*rotation, *location, *pTransform;
	double		viewZ;
	double		transMatrix[4][4], transform[4][4], rotMatrix[4][4];
	IDL_LONG	size[] = {4,4};
	IDL_VPTR	oTransform;

	for (n = 0; n < 2; ++n)
		IDL_ENSURE_ARRAY(argv[n]);
	IDL_ENSURE_SCALAR(argv[2]);

	rotation = (double *) argv[0]->value.arr->data;
	location = (double *) argv[1]->value.arr->data;
	viewZ = IDL_DoubleScalar(argv[2]);

	for (n = 0; n < 4; ++n) {
		for (o = 0; o < 4; ++o) 
			rotMatrix[n][o] = rotation[n*4+o];
	}

	IDENTMAT4(transMatrix);

	transMatrix[0][3] = -location[0];
	transMatrix[1][3] = -location[1];
	transMatrix[2][3] = -location[2];

	MXM4(transform, rotMatrix, transMatrix);

	transMatrix[0][3] = 0.0;
	transMatrix[1][3] = 0.0;
	transMatrix[2][3] = viewZ;

	MXM4d(transform, transMatrix, transform);

	pTransform = (double *) IDL_MakeTempArray((int)IDL_TYP_DOUBLE, 2, size,
		IDL_ARR_INI_NOP, &oTransform);

	for (n = 0; n<4; n++) {
		for (o = 0; o<4; o++) 
			pTransform[n*4+o] = transform[n][o];
	}

	return oTransform;

}


//  RHTgrCamera_VertT3D
IDL_VPTR IDL_CDECL RHTgrCamera_VertT3D(int argc, IDL_VPTR *argv, char *argk)
{
	/*

		Tvertices = RHTgrCamera_VertT3D(vertices, transform)

	*/

	int			n,o;
	double		*pTrans1d, *pVerts1d, *pTVerts;
	double		vertex[3], transform[4][4];
	IDL_LONG	size[] = {3,0};
	IDL_VPTR	oVerts;

	for (n = 0; n < 2; ++n)
		IDL_ENSURE_ARRAY(argv[n]);

	pVerts1d = (double *) argv[0]->value.arr->data;
	pTrans1d = (double *) argv[1]->value.arr->data;
	size[1] = argv[0]->value.arr->dim[1];
	
	pTVerts = (double *) IDL_MakeTempArray((int)IDL_TYP_DOUBLE, 2, size,
		IDL_ARR_INI_NOP, &oVerts);

	for (n = 0; n < 4; ++n) {
		for (o = 0; o < 4; ++o) 
			transform[n][o] = pTrans1d[n*4+o];
	}
	for (n = 0; n < size[1]; ++n) {
			vertex[0] = pVerts1d[n*3];
			vertex[1] = pVerts1d[n*3+1];
			vertex[2] = pVerts1d[n*3+2];
			M4XV3d(vertex,transform,vertex);
			pTVerts[n*3] = vertex[0];
			pTVerts[n*3+1] = vertex[1];
			pTVerts[n*3+2] = vertex[2];
	}

	return oVerts;

}


//  RHTgrCamera_ComputeFrustum
IDL_VPTR IDL_CDECL RHTgrCamera_ComputeFrustum(int argc, IDL_VPTR *argv, char *argk)
{
	/*

		frustVerts = RHTgrCamera_ComputeFrustum(zclip, fov, eye, PLANES=p)
		
	*/

	int				n,o,p;
	IDL_LONG		size[] = {3,0};
	double			l, xnear, ynear, xfar, yfar, zfar, lvn;
	double			frustum[8][3], planes[6][4], vertices[3][3];
	double			eye, *zclip, *fov, *viewcoord;
	double			*pFrustum, *pPlanes;
	IDL_VPTR		oFrustum, outargs[3];
	static IDL_VPTR oPlanes, oTemp;

	static IDL_KW_PAR keywords[]={
		{"PLANES", IDL_TYP_UNDEF, 1, IDL_KW_OUT|IDL_KW_ZERO,0,IDL_CHARA(oPlanes)},
		{NULL}
	};

	IDL_KWCleanup(IDL_KW_MARK);
	IDL_KWGetParams(argc, argv, argk, keywords, outargs, 1);

	IDL_ENSURE_ARRAY(outargs[0]);
	IDL_ENSURE_ARRAY(outargs[1]);
	IDL_ENSURE_SCALAR(outargs[2]);

	zclip = (double *) outargs[0]->value.arr->data;
	fov = (double *) outargs[1]->value.arr->data;
	eye = IDL_DoubleScalar(outargs[2]);
	
	l = eye - zclip[0];
	xnear = l * tan(fov[0]);
	ynear = l * tan(fov[1]);
	l = eye - zclip[1];
	xfar = l * tan(fov[0]);
	yfar = l * tan(fov[1]);
	zfar = zclip[1] - zclip[0];

	frustum[0][0] = -xnear;
	frustum[0][1] = ynear;
	frustum[0][2] = zclip[0];
	frustum[1][0] = xnear;
	frustum[1][1] = ynear;
	frustum[1][2] = zclip[0];
	frustum[2][0] = xnear;
	frustum[2][1] = -ynear;
	frustum[2][2] = zclip[0];
	frustum[3][0] = -xnear;
	frustum[3][1] = -ynear;
	frustum[3][2] = zclip[0];
	frustum[4][0] = -xfar;
	frustum[4][1] = yfar;
	frustum[4][2] = zclip[1];
	frustum[5][0] = xfar;
	frustum[5][1] = yfar;
	frustum[5][2] = zclip[1];
	frustum[6][0] = xfar;
	frustum[6][1] = -yfar;
	frustum[6][2] = zclip[1];
	frustum[7][0] = -xfar;
	frustum[7][1] = -yfar;
	frustum[7][2] = zclip[1];

	if (oPlanes) {

		for (n = 0; n < 6; ++n) {
			for (o = 0; o < 3; ++o) {
				for (p = 0; p < 3; ++p)
					vertices[o][p] = frustum[faceConn[n][o]][p];
			}
			get_polygon_normal(planes[n], 3, vertices);
			planes[n][3] = -(planes[n][0]*vertices[1][0] + planes[n][1]*vertices[1][1] + 
				planes[n][2]*vertices[1][2]);
		}

		size[0] = 4;
		size[1] = 6;
		pPlanes = (double *) IDL_MakeTempArray((int)IDL_TYP_DOUBLE, 2, size,
			IDL_ARR_INI_NOP, &oTemp);

		for (n = 0; n<6; n++) {
			for (o = 0; o<4; o++) 
				pPlanes[n*4+o] = planes[n][o];
		}

		IDL_VarCopy(oTemp, oPlanes);
	}

	size[0] = 3;
	size[1] = 8;
	pFrustum = (double *) IDL_MakeTempArray((int)IDL_TYP_DOUBLE, 2, size,
		IDL_ARR_INI_NOP, &oFrustum);

	for (n = 0; n<8; n++) {
		for (o = 0; o<3; o++) 
			pFrustum[n*3+o] = frustum[n][o];
	}

	IDL_KWCleanup(IDL_KW_CLEAN);

	return oFrustum;

}


/*  RHTgrCamera_AABBIntersectFrustum */
IDL_VPTR IDL_CDECL RHTgrCamera_AABBIntersectFrustum(int argc, IDL_VPTR *argv, char *argk)
{

    /*

		inview = RHTgrCamera_AABBIntersectFrustum(location, extents, frustPlanes, $
				     CLIPMASK=clip)

    */

	short			p, intx;
	short			*intersect, *clipMask;
	IDL_LONG		nbox, nbdx, pldx, size[] = {1};
	double			*location, *extents, *planes;
	double			NP, MP, loc[3], ext[3];
	IDL_VPTR		oIntersect, outargv[3];
	static IDL_VPTR oClipMask, oTemp;

	static IDL_KW_PAR keywords[]={
		{"CLIPMASK", IDL_TYP_UNDEF, 1, IDL_KW_OUT|IDL_KW_ZERO,0,IDL_CHARA(oClipMask)},
		{NULL}
	};

	IDL_KWGetParams(argc,argv,argk, keywords,outargv,1);

	for (p = 0; p < 3; ++p)
		IDL_ENSURE_ARRAY(outargv[p]);

	if (outargv[0]->value.arr->n_elts != outargv[1]->value.arr->n_elts ||
		outargv[0]->value.arr->n_dim > 2) return IDL_GettmpInt(-3);

	location = (double *) outargv[0]->value.arr->data;
	extents = (double *) outargv[1]->value.arr->data;
	planes = (double *) outargv[2]->value.arr->data;
	size[0] = outargv[0]->value.arr->dim[1];

	intersect = (short *) IDL_MakeTempArray((int)IDL_TYP_INT, 1, 
		size, IDL_ARR_INI_NOP, &oIntersect);
	if (oClipMask) {
		clipMask = (short *) IDL_MakeTempArray((int)IDL_TYP_INT, 1, size,
			IDL_ARR_INI_ZERO, &oTemp);
	}

	/*

		Test frustum / AABB intersection.

	    Adapted from code posted to the GDAlgorithms list by Ville Miettinen
	    and deconstruction by Per Vognsen in Bruce Mitchener's "scratch area":
	    http://agora.cubik.org/wiki/view/Scratch/WebHome

	*/

	for (nbox = 0; nbox < size[0]; ++nbox) {

		nbdx = nbox * 3;
		intx = 1;

		for (p = 0; p < 6; ++p) {

			pldx = p * 4;
			NP = extents[nbdx]*fabs(planes[pldx]) + extents[nbdx+1]*fabs(planes[pldx+1]) +
				extents[nbdx+2]*fabs(planes[pldx+2]);
			MP = location[nbdx]*planes[pldx] + location[nbdx+1]*planes[pldx+1] +
				location[nbdx+2]*planes[pldx+2] + planes[pldx+3];

			if ((MP+NP) < 0.0) {
				intersect[nbox] = 0;
				intx = 0;
				p = 6;
				continue;
			}
			
			if ((oClipMask) && ((MP-NP) < 0.0)) clipMask[nbox] |= p;
		}

		if (intx) intersect[nbox] = 1;

	}

	if (oClipMask) IDL_VarCopy(oTemp, oClipMask);

	return oIntersect;

}


int IDL_Load(void)
{

	static IDL_SYSFUN_DEF2 function_addr[] = {
		{(IDL_SYSRTN_GENERIC) RHTgrCamera_AABBIntersectFrustum, "RHTGRCAMERA_AABBINTERSECTFRUSTUM", 3, 3, 
			IDL_SYSFUN_DEF_F_KEYWORDS, 0},
		{(IDL_SYSRTN_GENERIC) RHTgrCamera_ComputeFrustum, "RHTGRCAMERA_COMPUTEFRUSTUM", 3, 3, 
			IDL_SYSFUN_DEF_F_KEYWORDS, 0},
		{(IDL_SYSRTN_GENERIC) RHTgrCamera_Transform, "RHTGRCAMERA_TRANSFORM", 3, 3, 0, 0},
		{(IDL_SYSRTN_GENERIC) RHTgrCamera_VertT3D, "RHTGRCAMERA_VERTT3D", 2, 2, 0, 0},
	};

	return IDL_SysRtnAdd(function_addr, TRUE, ARRLEN(function_addr));
}
