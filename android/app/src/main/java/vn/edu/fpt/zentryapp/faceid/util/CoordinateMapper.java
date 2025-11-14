package vn.edu.fpt.zentryapp.faceid.util;

import android.graphics.RectF;

/**
 * Compatibility shim for legacy package references to CoordinateMapper.
 * Delegates to the implementation in com.example.flutter_application_1.faceid.util.CoordinateMapper.
 */
public final class CoordinateMapper {
    private static final CoordinateMapper INSTANCE = new CoordinateMapper();
    private final com.example.flutter_application_1.faceid.util.CoordinateMapper delegate =
            com.example.flutter_application_1.faceid.util.CoordinateMapper.getInstance();

    public static CoordinateMapper getInstance() {
        return INSTANCE;
    }

    private CoordinateMapper() {}

    public void updateMapping(int viewWidth, int viewHeight, int bitmapWidth, int bitmapHeight, boolean mirrorX) {
        delegate.updateMapping(viewWidth, viewHeight, bitmapWidth, bitmapHeight, mirrorX);
    }

    public void updateMappingWithPolicy(int viewWidth, int viewHeight, int bitmapWidth, int bitmapHeight,
                                        boolean isPreviewMirrored, boolean isBitmapMirrored) {
        delegate.updateMappingWithPolicy(viewWidth, viewHeight, bitmapWidth, bitmapHeight, isPreviewMirrored, isBitmapMirrored);
    }

    public RectF mapViewRectToBitmap(RectF viewRect) {
        return delegate.mapViewRectToBitmap(viewRect);
    }

    public RectF mapBitmapRectToView(RectF bitmapRect) {
        return delegate.mapBitmapRectToView(bitmapRect);
    }

    public Mapping getMapping() {
        com.example.flutter_application_1.faceid.util.CoordinateMapper.Mapping m = delegate.getMapping();
        if (m == null) return null;
        return new Mapping(m.viewWidth, m.viewHeight, m.bitmapWidth, m.bitmapHeight, m.mirrorX);
    }

    // Lightweight Mapping copy to avoid cross-package type issues
    public static final class Mapping {
        public final int viewWidth;
        public final int viewHeight;
        public final int bitmapWidth;
        public final int bitmapHeight;
        public final boolean mirrorX;

        public Mapping(int viewWidth, int viewHeight, int bitmapWidth, int bitmapHeight, boolean mirrorX) {
            this.viewWidth = viewWidth;
            this.viewHeight = viewHeight;
            this.bitmapWidth = bitmapWidth;
            this.bitmapHeight = bitmapHeight;
            this.mirrorX = mirrorX;
        }
    }
}
