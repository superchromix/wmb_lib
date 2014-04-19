/* 
Copy a string to the Windows system clipboard.
This code is based on WINCLIP.C written by Peter Mason.

Mark Bates
August 14, 2013
*/


#define STRICT
#define VC_EXTRALEAN
#include <windows.h>
#define SZD sizeof(double)
#define XSPCALL WINAPI
#include <float.h>


/*****************************************************************************/
BOOL WINAPI DllMain(HINSTANCE hinst, unsigned long reason, void *resvd)
{
	hinst=hinst;  
    reason=reason;  
    resvd=resvd;	//just access the vars to suppress compiler warnings
	return 1;
}



/******************************************************************************/
int XSPCALL wmb_copy_to_clipboard(int ac, char *a[])
/*
   Sticks the data in a[0] onto the clipboard.

   Takes 2 args in *a[] (passed by reference):

   char *objectInMemory         the data (usually a BYTARR in IDL)
   long *numBytes               size of the data, including any trailing \0

   Note that objectInMemory must be set up (by you) according to type.
   Returns 0 on success, 1 on failure.
*/
{
    char   *txtin,*globh;
    HANDLE th;
    int    cfmt=0,ntxt,rv=1;

    if(ac!=2) {
        MessageBox(NULL,"wmb_copy_to_clipboard() requires 2 arguments.","Error",MB_OK | MB_ICONSTOP);
        return rv;
    }

    txtin=a[0];  
    ntxt= *((int *)a[1]);

    if(OpenClipboard(NULL)==FALSE) goto clipitX;

    rv=2;
    
    if(EmptyClipboard()==FALSE) goto clipitX;

    cfmt=CF_TEXT;

    if((th=GlobalAlloc(GMEM_MOVEABLE | GMEM_DDESHARE,ntxt))==NULL) goto clipitX;

    if((globh=GlobalLock(th))==NULL) { GlobalFree(th);  goto clipitX; }

    memcpy(globh,txtin,ntxt);  
    GlobalUnlock(th);

    if(SetClipboardData(cfmt,th)==NULL) { GlobalFree(th);  goto clipitX; }

    if(CloseClipboard()==FALSE) goto clipitX;

    rv=0;

clipitX:
    if(rv) {		/* something went wrong */

        if(rv==2) {CloseClipboard(); rv=1;}
        MessageBox(NULL,"Failed to copy to clipboard","Error",MB_OK | MB_ICONSTOP);
        
    }

    return rv;
}

/******************************************************************************/
/*
	This one checks whether there's a CF_TEXT format thing on the clipboard.
	If not, it returns 0, otherwise it returns the number of bytes of the CF_TEXT thing.
*/
int XSPCALL wmb_test_clipboard_text()
{
	char		*tx;
	HANDLE	hc;
	int			rv=0;

	if(OpenClipboard(NULL)==FALSE) return 0;
	if(!IsClipboardFormatAvailable(CF_TEXT)) goto bye;
	if(!(hc=GetClipboardData(CF_TEXT))) goto bye;
	if(!(tx=GlobalLock(hc))) goto bye;

	rv=lstrlen(tx)+1;           /* this is basically what we came for! */
	GlobalUnlock(hc);

bye:
	CloseClipboard();
	return rv;
}

/******************************************************************************/
/*
	This one retrieves a CF_TEXT-format thing from the clipboard.
	One will typically have called idliscliptxt() to check if one's there and to get its size.

	2 parameters are passed:

	.	The address of an IDL variable (typically a BYTARR, not a STRARR) to collect the data

	. The size of the IDL variable, in bytes.   If this is too small then only a part of the
		CF_TEXT thing will be retrieved.   On return this parameter is updated with the #bytes
		actually pasted.

	This function returns 0 if all went OK, else 1.
*/

int XSPCALL wmb_paste_from_clipboard(int ac, char *a[])
{
	char		*tx,*idltx;
	int			*idlnb;
	HANDLE	hc;
	int			tl,tl1,rv=1;

	if(ac!=2) return 1;                         /* we insist on 2 parameters from IDL */

	idltx=a[0];  idlnb=(int *)a[1];
	if((tl=*idlnb)<=1) return 1;                /* IDL buffer just too small to be of use for anything */

	*idlnb=0;                                   /* tell IDL we've copied 0 bytes (for now) */

	if(OpenClipboard(NULL)==FALSE) return 1;
	if(!IsClipboardFormatAvailable(CF_TEXT)) goto bye;
	if(!(hc=GetClipboardData(CF_TEXT))) goto bye;
	if(!(tx=GlobalLock(hc))) goto bye;
	if((tl1=lstrlen(tx)+1)<=1) goto bye;        /* this is the size of the clipboard object (fail if there's nothing there) */
	if(tl1<tl) tl=tl1;                          /* if we don't have room then take what we can, else take what's there */

	memcpy(idltx,tx,tl);
	idltx[tl-1]=0;              /* ensure NULL termination */
	GlobalUnlock(hc);
	*idlnb=tl;                  /* return the number of bytes we copied */
	rv=0;                       /* success */

bye:
	CloseClipboard();
	return rv;
}
