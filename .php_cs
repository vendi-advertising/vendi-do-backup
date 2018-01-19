<?php

$finder = PhpCsFixer\Finder::create()
    ->in('src/')
;

return PhpCsFixer\Config::create()
    ->setRules([
        '@PSR1' => true,
        '@PSR2' => true,
        'array_syntax' => ['syntax' => 'short'],
        'cast_spaces' => ['space' => 'single'],

        //We are using ::class in our code and this freaks symfony out if set to true
        'class_keyword_remove' => false,

        //We need PHP 5.6 support so we can't use this
        'declare_strict_types' => false,
        'lowercase_cast' => true,

        //NOTE: Do not change!!!
        'mb_str_functions' => false,


        'method_separation' => true,
        'no_empty_statement' => true,
        'no_homoglyph_names' => true,
        'no_leading_import_slash' => true,
        'no_mixed_echo_print' => ['use' => 'echo'],
        'no_php4_constructor' => true,
        'no_short_bool_cast' => true,
        'no_short_echo_tag' => true,
        'no_unused_imports' => true,
        'non_printable_character' => ['use_escape_sequences_in_strings' => true],
        'ordered_imports' => ['sortAlgorithm' => 'alpha'],

        'php_unit_construct' => true,
        'php_unit_dedicate_assert' => true,
        'php_unit_fqcn_annotation' => true,
        'php_unit_strict' => true,
        'php_unit_test_class_requires_covers' => true,

        'phpdoc_add_missing_param_annotation' => true,
        'phpdoc_align' => ['tags' => ['param', 'return', 'throws', 'type', 'var'] ],
        'phpdoc_annotation_without_dot' => true,
        'phpdoc_indent' => true,
        'phpdoc_no_empty_return' => true,
        'phpdoc_order' => true,
        'phpdoc_scalar' => true,
        'phpdoc_summary' => true,
        'phpdoc_trim' => true,
        'phpdoc_types' => true,

        'short_scalar_cast' => true,
        'single_quote' => true,
        'strict_comparison' => true,
    ])
    ->setFinder($finder)
    ->setUsingCache(true)
    ->setRiskyAllowed(true)
;
