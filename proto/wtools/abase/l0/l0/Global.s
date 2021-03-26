( function _Global_s_()
{

'use strict';

// global

let _global = undefined;
if( typeof _global_ !== 'undefined' && _global_._global_ === _global_ )
_global = _global_;
else if( typeof globalThis !== 'undefined' && globalThis.globalThis === globalThis )
_global = globalThis;
else if( typeof Global !== 'undefined' && Global.Global === Global )
_global = Global;
else if( typeof global !== 'undefined' && global.global === global )
_global = global;
else if( typeof window !== 'undefined' && window.window === window )
_global = window;
else if( typeof self   !== 'undefined' && self.self === self )
_global = self;
if( !_global._globals_ )
{
  _global._globals_ = Object.create( null );
  _global._globals_.real = _global;
  _global._realGlobal_ = _global;
  _global._global_ = _global;
}

//

//globalNamespaceOpen
function _new( name, global )
{
  // const Module = require( 'module' );

  if( _realGlobal_._globals_[ name ] )
  throw Error( `Global namespace::${name} already exists!` );

  let global2 = _realGlobal_._globals_[ name ] = Object.create( global || _realGlobal_ );
  global2.__GLOBAL_NAME__ = name;
  global2.wTools = Object.create( null );
  global2.wTools.global = Object.create( null );
  global2.wTools.global.current = global2;
  global2.wTools.module = Object.create( null );
  global2.wTools.module.nativeFilesMap = Object.create( null );

  return global2;
  // return _realGlobal_.wTools.global.open( name );
}

//

function open( name )
{
  // const Module = require( 'module' );

  // _global_.wTools = Object.hasOwnProperty.call( _global_, 'wTools' ) ? _global_.wTools : Object.create( null );
  // _global_.wTools.global = _global_.wTools.global || Object.create( null );
  // _global_.wTools.global.current = _global_.wTools.global.current || _global_;
  // _global_.wTools.module = _global_.wTools.module || Object.create( null );
  // _global_.wTools.module.nativeFilesMap = _global_.wTools.module.nativeFilesMap || Module._cache;

  if( !_global_.wTools.global.current )
  throw Error( 'Global namespace is not setup' );
  if( !_global_.wTools.module.nativeFilesMap )
  throw Error( 'Global namespace is not setup' );

  if( !_globals_[ name ] )
  throw Error( `Global namespace::${name} deos not exist!` );
  if( !_global_.__GLOBAL_NAME__ )
  throw Error( `Current global namespace deos not have name!` );
  if( _global_.wTools.module.nativeFilesMap !== Module._cache )
  throw Error( `Current global have native module files map of different global` );

  _realGlobal_.wTools.global._stack.push
  ({
    name : _global_.__GLOBAL_NAME__,
    global : _global_,
    moduleNativeFilesMap : Module._cache,
  });

  let global2 = _globals_[ name ];
  _realGlobal_._global_ = global2;
  Module._cache = global2.wTools.module.nativeFilesMap;

  return global2;
}

//

// globalNamespaceClose
function close( name )
{
  // const Module = require( 'module' );

  if( name !== _global_.__GLOBAL_NAME__ )
  throw Error( `Current global is ${_global_.__GLOBAL_NAME__}, not ${name}` );
  if( _global_.wTools.module.nativeFilesMap !== Module._cache )
  throw Error( `Current global have native module files map of different global` );
  if( !_realGlobal_.wTools.global._stack.length )
  throw Error( `Nothing to close` );

  let was = _realGlobal_.wTools.global._stack.pop();
  Module._cache = was.moduleNativeFilesMap;
  _realGlobal_._global_ = was.global;
}

//

function openForChildren( name, moduleFile )
{
  let moduleNativeFile = __.module.fileNativeFrom( moduleFile );

  let global2 = _globals_[ name ];

  if( !!moduleNativeFile._virtualEnvironment )
  throw Error( `Module already have virtual environment ${moduleNativeFile._virtualEnvironment.name}` );
  if( !_globals_[ name ] )
  throw Error( `Global namespace::${name} deos not exist!` );
  if( !global2.wTools.module.nativeFilesMap )
  throw Error( `Global namespace::${name} deos not have defined module.nativeFilesMap!` );

  let env = moduleNativeFile._virtualEnvironment = Object.create( null );
  env.name = global2.__GLOBAL_NAME__;
  env.global = global2;
  env.moduleNativeFilesMap = global2.wTools.module.nativeFilesMap;

}

//

function closeForChildren( name, moduleFile )
{
  let moduleNativeFile = __.module.fileNativeFrom( moduleFile );

  if( !moduleNativeFile._virtualEnvironment )
  throw Error( `Module deos not have virtual environment` );
  if( moduleNativeFile._virtualEnvironment.name !== name )
  throw Error( `Not global::${name} is not associated global` )

  delete moduleNativeFile._virtualEnvironment;

}

//

function setup( global, name )
{

  if( !name )
  throw Error( 'Expects name of the global' );
  if( Object.hasOwnProperty.call( global, '__GLOBAL_NAME__' ) && global.__GLOBAL_NAME__ !== name )
  throw Error( `The global have name ${global.__GLOBAL_NAME__}, not ${name}` );
  global.__GLOBAL_NAME__ = Object.hasOwnProperty.call( global, '__GLOBAL_NAME__' ) ? global.__GLOBAL_NAME__ : name;

  global.wTools = Object.hasOwnProperty.call( global, 'wTools' ) ? global.wTools : Object.create( null );

  global.wTools.global = global.wTools.global || Object.create( null );
  if( global.wTools.global.current && global.wTools.global.current !== global )
  throw Error( 'The global refers to different global. Something wrong!' );
  global.wTools.global.current = global.wTools.global.current || global;

  global.wTools.module = global.wTools.module || Object.create( null );
  if( typeof module !== 'undefined' )
  if( global.wTools.module.nativeFilesMap && global.wTools.module.nativeFilesMap !== require( 'module' )._cache )
  throw Error( `The global have native module files map of different global. Something wrong!` );
  if( typeof module !== 'undefined' )
  global.wTools.module.nativeFilesMap = global.wTools.module.nativeFilesMap || require( 'module' )._cache;

}

//

/* qqq xxx : cover */
function fileNativeIs( src )
{
  if( !src )
  return false;
  if( !Module )
  return true;
  return src instanceof Module;
}

//

/* qqq xxx : cover */
function fileUniversalIs( src )
{
  if( !src )
  return false;
  if( !src.constructor )
  return false;
  return src.constructor.name === 'ModuleFile';
}

//

function fileNativeFrom( src )
{
  if( __.module.fileNativeIs( src ) )
  return src;
  if( __.module.fileUniversalIs( src ) )
  return src.moduleNativeFile || undefined;
  return undefined;
}

//

const Module = typeof module !== 'undefined' ? require( 'module' ) : null;
const __ = _realGlobal_.wTools = _realGlobal_.wTools || Object.create( null );
__.global = __.global || Object.create( null );
// __.global.current = __.global.current || _realGlobal_;
__.module = __.module || Object.create( null );
// __.module.nativeFilesMap = __.module.nativeFilesMap || ( typeof module !== 'undefined' ? require( 'module' )._cache : null );

__.global._stack = __.global._stack || [];
__.global.new = __.global.new || _new;
__.global.open = __.global.open || open;
__.global.close = __.global.close || close;
__.global.openForChildren = __.global.openForChildren || openForChildren;
__.global.closeForChildren = __.global.closeForChildren || closeForChildren;
__.global.setup = __.global.setup || setup;

__.module.fileNativeIs = __.module.fileNativeIs || fileNativeIs;
__.module.fileUniversalIs = __.module.fileUniversalIs || fileUniversalIs;
__.module.fileNativeFrom = __.module.fileNativeFrom || fileNativeFrom;

if( _global_ === _realGlobal_ )
__.global.setup( _realGlobal_, 'real' );

//

})();
