<?php

if (!extension_loaded('pcre')) {
    return;
}

if (!function_exists('ereg_replace')) {
    function ereg_replace($pattern, $replacement, $string) {
        return preg_replace(
            '/' . str_replace('/', '\\/', str_replace('\\/', '/', $pattern)) . '/',
            $replacement,
            $string
        );
    }
}

if (!function_exists('ereg')) {
    function ereg($pattern, $string, array &$regs = NULL) {
        return preg_match(
            '/' . str_replace('/', '\\/', str_replace('\\/', '/', $pattern)) . '/',
            $string,
            $regs
        );
    }
}

if (!function_exists('eregi_replace')) {
    function eregi_replace($pattern, $replacement, $string) {
        return preg_replace(
            '/' . str_replace('/', '\\/', str_replace('\\/', '/', $pattern)) . '/i',
            $replacement,
            $string
        );
    }
}

if (!function_exists('eregi')) {
    function eregi($pattern, $string, array &$regs = NULL) {
        return preg_match(
            '/' . str_replace('/', '\\/', str_replace('\\/', '/', $pattern)) . '/i',
            $string,
            $regs
        );
    }
}

if (!function_exists('split')) {
    function split($pattern, $string, $limit = -1) {
        if ($pattern === '') {
            trigger_error(__FUNCTION__ . ': REG_EMPTY', E_WARNING);
            return false;
        }
        return preg_split(
            '/' . str_replace('/', '\\/', str_replace('\\/', '/', $pattern)) . '/',
            $string,
            $limit
        );
    }
}

if (!function_exists('spliti')) {
    function spliti($pattern, $string, $limit = -1) {
        if ($pattern === '') {
            trigger_error(__FUNCTION__ . ': REG_EMPTY', E_WARNING);
            return false;
        }
        return preg_split(
            '/' . str_replace('/', '\\/', str_replace('\\/', '/', $pattern)) . '/i',
            $string,
            $limit
        );
    }
}

