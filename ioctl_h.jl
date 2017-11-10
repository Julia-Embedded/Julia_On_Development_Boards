#ifndef _ASM_GENERIC_IOCTL_H
#define _ASM_GENERIC_IOCTL_H

#*********************************************************************
# ioctl command encoding: 32 bits total, command in lower 16 bits,
# * size of the parameter structure in the lower 14 bits of the
# * upper 16 bits.
# * Encoding the size of the parameter structure in the ioctl request
# * is useful for catching programs compiled with old versions
# * and to avoid overwriting user space outside the user buffer area.
# * The highest 2 bits are reserved for indicating the ``access mode''.
# * NOTE: This limits the max parameter size to 16kB -1 !
# 
#
#
# * The following is for compatibility across the various Linux
# * platforms.  The generic ioctl numbering scheme doesn't really enforce
# * a type field.  De facto, however, the top 8 bits of the lower 16
# * bits are indeed used as a type field, so we might just as well make
# * this explicit here.  Please be sure to use the decoding macros
# * below from now on. 
 #*********************************************************************
const   _IOC_NRBITS	                    =   8
const   _IOC_TYPEBITS	                =   8

#*********************************************************************
# * Let any architecture override either of the following before
# * including this file.
#********************************************************************* 

#ifndef _IOC_SIZEBITS
const    _IOC_SIZEBITS	                =   14
#endif

#ifndef _IOC_DIRBITS
const   _IOC_DIRBITS	                =   2
#endif

const   _IOC_NRMASK	                    =   ((1 << _IOC_NRBITS)-1)
const   _IOC_TYPEMASK	                =   ((1 << _IOC_TYPEBITS)-1)
const   _IOC_SIZEMASK	                =   ((1 << _IOC_SIZEBITS)-1)
const   _IOC_DIRMASK	                =   ((1 << _IOC_DIRBITS)-1)

const   _IOC_NRSHIFT	                =   0
const   _IOC_TYPESHIFT	                =   (_IOC_NRSHIFT+_IOC_NRBITS)
const   _IOC_SIZESHIFT	                =   (_IOC_TYPESHIFT+_IOC_TYPEBITS)
const   _IOC_DIRSHIFT	                =   (_IOC_SIZESHIFT+_IOC_SIZEBITS)

#*********************************************************************
# * Direction bits, which any architecture can choose to override
# * before including this file.
#********************************************************************* 

#ifndef _IOC_NONE
const   _IOC_NONE	                    =   UInt32(0)
#endif

#ifndef _IOC_WRITE
const   _IOC_WRITE	                    =   UInt32(1)
#endif

#ifndef _IOC_READ
const   _IOC_READ	                    =   UInt32(2)
#endif

const   _IOC(dir,xtype,nr,size)         =   (((dir)  << _IOC_DIRSHIFT) | ((xtype) << _IOC_TYPESHIFT) | ((nr)   << _IOC_NRSHIFT) | ((size) << _IOC_SIZESHIFT))

const   _IOC_TYPECHECK(t)               =   (sizeof(t))

#*********************************************************************
# used to create numbers 
#*********************************************************************
const   _IO(xtype,nr)		            =   _IOC(_IOC_NONE,(xtype),(nr),0)
const   _IOR(xtype,nr,size)	            =   _IOC(_IOC_READ,(xtype),(nr),(_IOC_TYPECHECK(size)))
const   _IOW(xtype,nr,size)	            =   _IOC(_IOC_WRITE,(xtype),(nr),(_IOC_TYPECHECK(size)))
const   _IOWR(xtype,nr,size)	            =   _IOC(_IOC_READ|_IOC_WRITE,(xtype),(nr),(_IOC_TYPECHECK(size)))
const   _IOR_BAD(xtype,nr,size)	        =   _IOC(_IOC_READ,(xtype),(nr),sizeof(size))
const   _IOW_BAD(xtype,nr,size)	        =   _IOC(_IOC_WRITE,(xtype),(nr),sizeof(size))
const   _IOWR_BAD(xtype,nr,size)	        =   _IOC(_IOC_READ|_IOC_WRITE,(xtype),(nr),sizeof(size))

#*********************************************************************
# used to decode ioctl numbers.. 
#*********************************************************************
const   _IOC_DIR(nr)		            =   (((nr) >> _IOC_DIRSHIFT) & _IOC_DIRMASK)
const   _IOC_TYPE(nr)		            =   (((nr) >> _IOC_TYPESHIFT) & _IOC_TYPEMASK)
const   _IOC_NR(nr)		                =   (((nr) >> _IOC_NRSHIFT) & _IOC_NRMASK)
const   _IOC_SIZE(nr)		            =   (((nr) >> _IOC_SIZESHIFT) & _IOC_SIZEMASK)

#*********************************************************************
# ...and for the drivers/sound files... 
#*********************************************************************

const   IOC_IN		                    =   (_IOC_WRITE << _IOC_DIRSHIFT)
const   IOC_OUT		                    =   (_IOC_READ << _IOC_DIRSHIFT)
const   IOC_INOUT	                    =   ((_IOC_WRITE|_IOC_READ) << _IOC_DIRSHIFT)
const   IOCSIZE_MASK	                =   (_IOC_SIZEMASK << _IOC_SIZESHIFT)
const   IOCSIZE_SHIFT	                =   (_IOC_SIZESHIFT)

#endif # _ASM_GENERIC_IOCTL_H 

