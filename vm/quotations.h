void set_quot_xt(F_QUOTATION *quot, F_CODE_BLOCK *code);
void jit_compile(CELL quot, bool relocate);
F_FASTCALL CELL lazy_jit_compile_impl(CELL quot, F_STACK_FRAME *stack);
F_FIXNUM quot_code_offset_to_scan(CELL quot, F_FIXNUM offset);
void primitive_array_to_quotation(void);
void primitive_quotation_xt(void);
void primitive_jit_compile(void);
void compile_all_words(void);
