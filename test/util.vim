let s:util = themis#suite('util')

function! s:util.__parse_callstack__()
  let parse_callstack = themis#suite('parse_callstack()')
  function! parse_callstack.can_parse_sfile()
    let stacks = themis#util#parse_callstack(expand('<sfile>'))
    for stack in stacks
      Assert HasKey(stack, 'function')
      Assert HasKey(stack, 'line')
    endfor
    let laststack = stacks[-1]
    Assert Equals(laststack.function, themis#util#funcname(self.can_parse_sfile))
    Assert Equals(laststack.line, 0)
  endfunction
  function! parse_callstack.can_parse_throwpoint()
    try
      throw 'dummy'
    catch
      let stacks = themis#util#parse_callstack(v:throwpoint)
    endtry
    for stack in stacks
      Assert HasKey(stack, 'function')
      Assert HasKey(stack, 'line')
    endfor
    let laststack = stacks[-1]
    Assert Equals(laststack.function, themis#util#funcname(self.can_parse_throwpoint))
    Assert Equals(laststack.line, 2)
  endfunction
endfunction

function! s:util.__funcbody__()
  let funcbody = themis#suite('funcbody()')
  function! funcbody.takes_a_function_by_name()
    let body = themis#util#funcbody('SampleFuncForUtil', 0)
    Assert Match(body[1], '1\s*echo "line1"')
    Assert Match(body[-2], '\d\+\s*echo "lastline"')
  endfunction
  function! funcbody.takes_a_function_by_funcref()
    let body = themis#util#funcbody(function('SampleFuncForUtil'), 0)
    Assert Match(body[1], '1\s*echo "line1"')
    Assert Match(body[-2], '\d\+\s*echo "lastline"')
  endfunction
  function! funcbody.can_contain_defined_filename_info()
    let body = themis#util#funcbody('SampleFuncForUtil', 1)
    Assert Match(body[1], 'util\.vim$')
  endfunction
endfunction

function! s:util.funcline()
  Assert Match(themis#util#funcline('SampleFuncForUtil', 1), 'echo "line1"')
  Assert Match(themis#util#funcline('SampleFuncForUtil', 2), 'echo "line2"')
  Assert Match(themis#util#funcline('SampleFuncForUtil', 8), 'echo "lastline"')
endfunction

function! s:util.is_funcname()
  Assert True(themis#util#is_funcname('GlobalFunc'))
  Assert True(themis#util#is_funcname('s:script_local_func'))
  Assert True(themis#util#is_funcname('<SNR>10_script_local_func'))
  Assert True(themis#util#is_funcname('autoload#func'))
  Assert True(themis#util#is_funcname('10'))

  Assert False(themis#util#is_funcname(''))
  Assert False(themis#util#is_funcname('global_func'))
  Assert False(themis#util#is_funcname('g:global_func'))
  Assert False(themis#util#is_funcname('#func'))
  Assert False(themis#util#is_funcname('10func'))
endfunction

function! s:util.funcname()
  Assert Equals(themis#util#funcname(function('SampleFuncForUtil')), 'SampleFuncForUtil')
  Assert Match(themis#util#funcname(self.funcname), '^\d\+$')
endfunction

function! s:util.get_full_title()
  let obj1 = {}
  function! obj1.get_title()
    return 'foo'
  endfunction
  Assert Equals(themis#util#get_full_title(obj1), 'foo')

  let obj2 = {'parent': obj1}
  function! obj2.get_title()
    return 'bar'
  endfunction
  Assert Equals(themis#util#get_full_title(obj2), 'foo bar')

  let obj3 = {'parent': obj2}
  function! obj3.get_title()
    return ''
  endfunction
  Assert Equals(themis#util#get_full_title(obj3), 'foo bar')

  let obj4 = {'parent': obj3}
  function! obj4.get_title()
    return 'buz'
  endfunction
  Assert Equals(themis#util#get_full_title(obj4), 'foo bar buz')
endfunction

function! s:util.sortuniq()
  let original = ['foo', 'bar', 'foo', 'buz']
  let expect = ['bar', 'buz', 'foo']
  Assert Equals(themis#util#sortuniq(original), expect)
endfunction

function! SampleFuncForUtil()
  echo "line1"
  echo "line2"
  echo [
  \   0,
  \   1,
  \   2,
  \ ]
  echo "lastline"
endfunction
