#ifndef GLOW_FILTER_H
#define GLOW_FILTER_H

#ifndef CLAMP
#define CLAMP(x,a,b)        (((x) < (a)) ? (a) : (((x) > (b)) ? (b) : (x)))
#endif

#ifndef M_PI
#define M_PI       3.14159265358979323846
#endif

#ifndef M_PI_2
#define M_PI_2     1.57079632679489661923
#endif
#define CV2CARTESIAN(p, w, h, q) do {(q).x = (p).x - (w)/2; (q).y = (h)/2 - (p).y;} while (0)
#define CARTESIAN2CV(p, w, h, q) do {(q).x = (p).x + (w)/2; (q).y = (h)/2 - (p).y;} while (0)

#ifdef __cplusplus
extern "C" {
#endif

    struct _Image;

    int glow_filter_glow(struct _Image *image, const int color, const int radius, const float alpha);
    int glow_filter_drop_shadow(struct _Image *image, int xOffset, int yOffset, int grayVal, const float alpha);
    int glow_filter_poly_fit(struct _Image *image, const struct _Image *pstDrawImg, const int width, const float alpha);
    
#ifdef __cplusplus
};
#endif

#endif