use NativeCall;

class cairo_t is repr('CPointer') { }

class cairo_surface_t is repr('CPointer') { }

class cairo_pattern_t is repr('CPointer') { }

class cairo_matrix_t is repr('CPointer') { }

class cairo_rectangle_t is repr('CPointer') { }

class Cairo::Surface { ... }
class Cairo::RecordingSurface is Cairo::Surface { ... }
class Cairo::Image { ... }
class Cairo::Pattern { ... }
class Cairo::Context { ... }

enum Cairo::Format (
    "FORMAT_INVALID" => -1,
    "FORMAT_ARGB32"   ,
    "FORMAT_RGB24"    ,
    "FORMAT_A8"       ,
    "FORMAT_A1"       ,
    "FORMAT_RGB16_565",
    "FORMAT_RGB30"    ,
);

enum cairo_status_t <
    STATUS_SUCCESS

    STATUS_NO_MEMORY
    STATUS_INVALID_RESTORE
    STATUS_INVALID_POP_GROUP
    STATUS_NO_CURRENT_POINT
    STATUS_INVALID_MATRIX
    STATUS_INVALID_STATUS
    STATUS_NULL_POINTER
    STATUS_INVALID_STRING
    STATUS_INVALID_PATH_DATA
    STATUS_READ_ERROR
    STATUS_WRITE_ERROR
    STATUS_SURFACE_FINISHED
    STATUS_SURFACE_TYPE_MISMATCH
    STATUS_PATTERN_TYPE_MISMATCH
    STATUS_INVALID_CONTENT
    STATUS_INVALID_FORMAT
    STATUS_INVALID_VISUAL
    STATUS_FILE_NOT_FOUND
    STATUS_INVALID_DASH
    STATUS_INVALID_DSC_COMMENT
    STATUS_INVALID_INDEX
    STATUS_CLIP_NOT_REPRESENTABLE
    STATUS_TEMP_FILE_ERROR
    STATUS_INVALID_STRIDE
    STATUS_FONT_TYPE_MISMATCH
    STATUS_USER_FONT_IMMUTABLE
    STATUS_USER_FONT_ERROR
    STATUS_NEGATIVE_COUNT
    STATUS_INVALID_CLUSTERS
    STATUS_INVALID_SLANT
    STATUS_INVALID_WEIGHT
    STATUS_INVALID_SIZE
    STATUS_USER_FONT_NOT_IMPLEMENTED
    STATUS_DEVICE_TYPE_MISMATCH
    STATUS_DEVICE_ERROR
    STATUS_INVALID_MESH_CONSTRUCTION
    STATUS_DEVICE_FINISHED

    STATUS_LAST_STATUS
>;

enum Cairo::LineCap <
    LINE_CAP_BUTT
    LINE_CAP_ROUND
    LINE_CAP_SQUARE
>;

enum Cairo::Content (
    CONTENT_COLOR => 0x1000,
    CONTENT_ALPHA => 0x2000,
    CONTENT_COLOR_ALPHA => 0x3000,
);

sub cairo_format_stride_for_width(int $format, int $width)
    returns int
    is native('libcairo')
    {*}

class Cairo::Surface {
    has $.surface;

    sub cairo_surface_write_to_png(cairo_surface_t $surface, Str $filename)
        returns int
        is native('libcairo')
        {*}

    sub cairo_surface_reference(cairo_surface_t $surface)
        returns cairo_surface_t
        is native('libcairo')
        {*}

    sub cairo_surface_destroy(cairo_surface_t $surface)
        is native('libcairo')
        {*}

    method write_png(Str $filename) {
        my $result = cairo_surface_write_to_png($!surface, $filename);
        fail cairo_status_t($result) if $result != STATUS_SUCCESS;
        cairo_status_t($result);
    }

    method reference() { cairo_surface_reference($!surface) }
    method destroy  () { cairo_surface_destroy($!surface) }
}

class Cairo::RecordingSurface {
    sub cairo_recording_surface_create(int $content, cairo_rectangle_t $extents)
        returns cairo_surface_t
        is native('libcairo')
        {*}

    method new(Cairo::Content $content = CONTENT_COLOR_ALPHA) {
        my cairo_surface_t $surface = cairo_recording_surface_create($content.Int, OpaquePointer);
        my Cairo::RecordingSurface $rsurf = self.bless: :$surface;
        $rsurf.reference;
        $rsurf;
    }

    method record(&things, Cairo::Content :$content = CONTENT_COLOR_ALPHA) {
        my Cairo::Context $ctx .= new(my $surface = self.new($content));
        &things($ctx);
        $ctx.destroy();
        return $surface;
    }
}

class Cairo::Image {
    sub cairo_image_surface_create(int $format, int $width, int $height)
        returns cairo_surface_t
        is native('libcairo')
        {*}

    sub cairo_image_surface_create_for_data(Blob[uint8] $data, int $format, int $width, int $height, int $stride)
        returns cairo_surface_t
        is native('libcairo')
        {*}

    multi method create(Cairo::Format $format, Cool $width, Cool $height) {
        return Cairo::Surface.new(surface => cairo_image_surface_create($format.Int, $width.Int, $height.Int));
    }

    multi method create(Cairo::Format $format, Cool $width, Cool $height, Blob[uint8] $data, Cool $stride?) {
        if $stride eqv False {
            $stride = $width.Int;
        } elsif $stride eqv True {
            $stride = cairo_format_stride_for_width($format.Int, $width.Int);
        }
        return Cairo::Surface.new(surface => cairo_image_surface_create_for_data($data, $format.Int, $width.Int, $height.Int, $stride));
    }
}

class Cairo::Pattern {
    sub cairo_pattern_destroy(cairo_pattern_t $pat)
        is native('libcairo')
        {*}

    has $!pattern;

    method new($pattern) {
        self.bless(:$pattern)
    }

    method destroy() {
        cairo_pattern_destroy($!pattern);
    }
}

class Cairo::Context {
    sub cairo_create(cairo_surface_t $surface)
        returns cairo_t
        is native('libcairo')
        {*}

    sub cairo_destroy(cairo_t $ctx)
        is native('libcairo')
        {*}


    sub cairo_push_group(cairo_t $ctx)
        is native('libcairo')
        {*}

    sub cairo_pop_group(cairo_t $ctx)
        returns cairo_pattern_t
        is native('libcairo')
        {*}

    sub cairo_pop_group_to_source(cairo_t $ctx)
        is native('libcairo')
        {*}


    sub cairo_line_to(cairo_t $context, num $x, num $y)
        is native('libcairo')
        {*}

    sub cairo_move_to(cairo_t $context, num $x, num $y)
        is native('libcairo')
        {*}

    sub cairo_rel_line_to(cairo_t $context, num $x, num $y)
        is native('libcairo')
        {*}

    sub cairo_rel_move_to(cairo_t $context, num $x, num $y)
        is native('libcairo')
        {*}

    sub cairo_curve_to(cairo_t $context, num $x1, num $y1, num $x2, num $y2, num $x3, num $y3)
        is native('libcairo')
        {*}

    sub cairo_close_path(cairo_t $context)
        is native('libcairo')
        {*}

    sub cairo_rectangle(cairo_t $ctx, num $x, num $y, num $w, num $h)
        is native('libcairo')
        {*}


    sub cairo_set_source_rgb(cairo_t $context, num $r, num $g, num $b)
        is native('libcairo')
        {*}

    sub cairo_set_source_rgba(cairo_t $context, num $r, num $g, num $b, num $a)
        is native('libcairo')
        {*}

    sub cairo_set_line_cap(cairo_t $context, int $cap)
        is native('libcairo')
        {*}

    sub cairo_get_line_cap(cairo_t $context)
        returns int
        is native('libcairo')
        {*}

    sub cairo_set_line_width(cairo_t $context, num $width)
        is native('libcairo')
        {*}
    sub cairo_get_line_width(cairo_t $context)
        returns num
        is native('libcairo')
        {*}

    sub cairo_set_source_surface(cairo_t $context, cairo_surface_t $surface, num $x, num $y)
        is native('libcairo')
        {*}

    sub cairo_fill(cairo_t $ctx)
        is native('libcairo')
        {*}

    sub cairo_stroke(cairo_t $ctx)
        is native('libcairo')
        {*}

    sub cairo_fill_preserve(cairo_t $ctx)
        is native('libcairo')
        {*}

    sub cairo_stroke_preserve(cairo_t $ctx)
        is native('libcairo')
        {*}

    sub cairo_paint(cairo_t $ctx)
        is native('libcairo')
        {*}

    sub cairo_translate(cairo_t $ctx, num $tx, num $ty)
        is native('libcairo')
        {*}
    sub cairo_scale(cairo_t $ctx, num $sx, num $sy)
        is native('libcairo')
        {*}
    sub cairo_rotate(cairo_t $ctx, num $angle)
        is native('libcairo')
        {*}

    sub cairo_save(cairo_t $ctx)
        is native('libcairo')
        {*}
    sub cairo_restore(cairo_t $ctx)
        is native('libcairo')
        {*}

    sub cairo_status(cairo_t $ctx)
        returns int
        is native('libcairo')
        {*}

    has cairo_t $!context;

    multi method new(cairo_t $context) {
        self.bless(:$context);
    }

    multi method new(Cairo::Surface $surface) {
        my $context = cairo_create($surface.surface);
        self.bless(:$context);
    }

    method status {
        cairo_status_t(cairo_status($!context))
    }

    submethod BUILD(:$!context) { }

    method destroy() {
        cairo_destroy($!context)
    }


    method push_group() {
        cairo_push_group($!context);
    }

    method pop_group() returns Cairo::Pattern {
        Cairo::Pattern.new(cairo_pop_group($!context));
    }

    method pop_group_to_source() {
        cairo_pop_group_to_source($!context);
    }

    method save()    { cairo_save($!context) }
    method restore() { cairo_restore($!context) }

    multi method rgb(Cool $r, Cool $g, Cool $b) {
        cairo_set_source_rgb($!context, $r.Num, $g.Num, $b.Num);
    }
    multi method rgb(num $r, num $g, num $b) {
        cairo_set_source_rgb($!context, $r, $g, $b);
    }

    multi method rgba(Cool $r, Cool $g, Cool $b, Cool $a) {
        cairo_set_source_rgba($!context, $r.Num, $g.Num, $b.Num, $a.Num);
    }
    multi method rgb(num $r, num $g, num $b, num $a) {
        cairo_set_source_rgba($!context, $r, $g, $b, $a);
    }


    method set_source_surface(Cairo::Surface $surface, Cool $x = 0, Cool $y = 0) {
        cairo_set_source_surface($!context, $surface.surface, $x.Num, $y.Num)
    }

    multi method fill {
        cairo_fill($!context)
    }
    multi method stroke {
        cairo_stroke($!context)
    }
    multi method fill(:$preserve!) {
        cairo_fill_preserve($!context);
    }
    multi method stroke(:$preserve!) {
        cairo_stroke_preserve($!context);
    }

    method paint {
        cairo_paint($!context)
    }


    multi method move_to(Cool $x, Cool $y) {
        cairo_move_to($!context, $x.Num, $y.Num);
    }
    multi method line_to(Cool $x, Cool $y) {
        cairo_line_to($!context, $x.Num, $y.Num);
    }

    multi method move_to(Cool $x, Cool $y, :$relative!) {
        cairo_rel_move_to($!context, $x.Num, $y.Num);
    }
    multi method line_to(Cool $x, Cool $y, :$relative!) {
        cairo_rel_line_to($!context, $x.Num, $y.Num);
    }

    multi method curve_to(Cool $x1, Cool $y1, Cool $x2, Cool $y2, Cool $x3, Cool $y3) {
        cairo_curve_to($!context, $x1.Num, $y1.Num, $x2.Num, $y2.Num, $x3.Num, $y3.Num);
    }

    method close_path() {
        cairo_close_path($!context);
    }

    multi method rectangle(Cool $x, Cool $y, Cool $w, Cool $h) {
        cairo_rectangle($!context, $x.Num, $y.Num, $w.Num, $h.Num);
    }
    multi method rectangle(num $x, num $y, num $w, num $h) {
        cairo_rectangle($!context, $x, $y, $w, $h);
    }

    multi method translate(num $tx, num $ty) {
        cairo_translate($!context, $tx, $ty)
    }
    multi method translate(Cool $tx, Cool $ty) {
        cairo_translate($!context, $tx.Num, $ty.Num)
    }

    multi method scale(num $sx, num $sy) {
        cairo_scale($!context, $sx, $sy)
    }
    multi method scale(Cool $sx, Cool $sy) {
        cairo_scale($!context, $sx.Num, $sy.Num)
    }

    multi method rotate(num $angle) {
        cairo_rotate($!context, $angle)
    }
    multi method rotate(Cool $angle) {
        cairo_rotate($!context, $angle.Num)
    }

    method line_cap() {
        Proxy.new:
            FETCH => { Cairo::LineCap(cairo_get_line_cap($!context)) },
            STORE => -> \c, \value { cairo_set_line_cap($!context, value.Int) }
    }

    method line_width() {
        Proxy.new:
            FETCH => { cairo_get_line_width($!context) },
            STORE => -> \c, \value { cairo_set_line_width($!context, value.Num) }
    }
}
