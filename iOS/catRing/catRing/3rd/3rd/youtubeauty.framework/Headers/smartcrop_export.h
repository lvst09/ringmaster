
#ifndef SMARTCROP_EXPORT_H
#define SMARTCROP_EXPORT_H

#ifdef SMARTCROP_STATIC_DEFINE
#  define SMARTCROP_EXPORT
#  define SMARTCROP_NO_EXPORT
#else
#  ifndef SMARTCROP_EXPORT
#    ifdef smartcrop_EXPORTS
        /* We are building this library */
#      define SMARTCROP_EXPORT 
#    else
        /* We are using this library */
#      define SMARTCROP_EXPORT 
#    endif
#  endif

#  ifndef SMARTCROP_NO_EXPORT
#    define SMARTCROP_NO_EXPORT 
#  endif
#endif

#ifndef SMARTCROP_DEPRECATED
#  define SMARTCROP_DEPRECATED 
#  define SMARTCROP_DEPRECATED_EXPORT SMARTCROP_EXPORT 
#  define SMARTCROP_DEPRECATED_NO_EXPORT SMARTCROP_NO_EXPORT 
#endif

#define DEFINE_NO_DEPRECATED 0
#if DEFINE_NO_DEPRECATED
# define SMARTCROP_NO_DEPRECATED
#endif

#endif
