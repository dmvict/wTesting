(function _Tester_debug_s_() {

'use strict';

var _global = _global_;
var _ = _global_.wTools;
var sourceFileLocation = _.diagnosticLocation().full;
var sourceFileStack = _.diagnosticStack();

if( _.Tester._isFullImplementation )
{
  console.log( 'WARING : wTesting included several times!' );
  console.log( '' );
  console.log( 'First time' );
  console.log( _.Tester.sourceFileStack );
  console.log( '' );
  console.log( 'Second time' );
  console.log( sourceFileStack );
  console.log( '' );
  debugger;
  _.assert( 0 );
  return;
}

_.assert( _.toStr,'wTesting needs wTools/staging/dwtools/abase/layer1/StringTools.s' );
_.assert( _.execStages,'wTesting needs wTools/staging/dwtools/abase/layer1/ExecTools.s' );
_.assert( _.Consequence,'wTesting needs wConsequence/staging/dwtools/abase/oclass/Consequence.s' );

// --
// tester
// --

function exec()
{
  var tester = this;
  var result;

  try
  {

    _.assert( arguments.length === 0 );

    var appArgs = tester.appArgsApply();
    var path = tester.path;

    if( !tester.scenariosHelpMap[ tester.settings.scenario ] )
    throw _.errBriefly( 'Unknown scenario',tester.settings.scenario );

    if( tester.settings.scenario !== 'test' )
    if( !tester[ tester.scenariosActionMap[ tester.settings.scenario ] ] )
    throw _.errBriefly( 'Scenario',tester.settings.scenario,'is not implemented' );

    if( tester.settings.scenario === 'test' )
    {
      tester.includeTestsFrom( tester.path );
      result = tester.testAll();
    }
    else
    {
      tester[ tester.scenariosActionMap[ tester.settings.scenario ] ]();
    }

  }
  catch( err )
  {
    err = _.errLogOnce( err );
    process.exitCode = -1;
    _.beep();
    _.beep();
    return;
    throw err;
  }

}

//

function _registerExitHandler()
{
  var tester = this;

  _.appRepairExitHandler();

  if( tester._registerExitHandlerDone )
  return;

  tester._registerExitHandlerDone = 1;

  if( 0 )
  if( _global.process )
  process.on( 'exit', function()
  {
    if( tester.report && tester.report.testSuiteFailes && !process.exitCode )
    {
      var logger = tester.logger || _global.logger;
      debugger;
      logger.log( _.color.strFormat( 'Errors!','negative' ) );
      process.exitCode = -1;
    }
  });

}

//

function _includeTestsFrom( path )
{
  var tester = this;
  var logger = tester.logger || _global.logger;
  var path = _.pathJoin( _.pathCurrent(),path );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( path ) );

  if( tester.verbosity > 1 )
  logger.log( 'Includes tests from :',path,'\n' );

  var files = _.fileProvider.filesFind
  ({
    filePath : path,
    ends : [ '.test.s','.test.ss','.test.js' ],
    recursive : 1,
    maskAll : _.regexpMakeSafe(),
  });

  if( !files.length )
  {
    var record = _.fileProvider.fileRecord( path );
    if( record.stat && !record.stat.isDirectory() && record.inclusion )
    var files = [ record ];
  }

  for( var f = 0 ; f < files.length ; f++ )
  {
    if( !files[ f ].stat.isFile() )
    continue;
    var absolutePath = files[ f ].absolute;

    try
    {
      require( _.fileProvider.pathNativize( absolutePath ) );
    }
    catch( err )
    {
      debugger;
      err = _.errAttend( 'Cant include',absolutePath + '\n',err );
      tester.includeFails.push( err );

      logger.error( _.color.strFormatForeground( 'Cant include ' + absolutePath, 'red' ) );
      if( logger.verbosity > 3 )
      logger.error( _.err( err ) );
    }

  }

}

//

function includeTestsFrom( path )
{
  var tester = this;
  var logger = tester.logger || _global.logger;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( path ) );

  logger.verbosityPush( tester.verbosity === null ? tester._defaultVerbosity : tester.verbosity );
  tester._includeTestsFrom( path );
  logger.verbosityPop();

}

//

function appArgsApply()
{
  var tester = this;
  var logger = tester.logger || _global.logger;

  if( tester._appArgsApplied )
  return tester._appArgsApplied;

  _.assert( arguments.length === 0 );
  _.mapExtend( tester.settings,tester.Settings );

  var appArgs = _.appArgsInSamFormat();
  if( appArgs.map )
  {
    _.mapExtend( tester.settings,_.mapOnly( appArgs.map, tester.Settings ) );
    if( tester.verbosity >= 8 )
    logger.log( 'Raw application arguments :\n',_.toStr( appArgs,{ levels : 2 } ) );
    if( tester.verbosity >= 5 )
    logger.log( 'Application arguments :\n',_.toStr( _.mapOnly( appArgs.map, tester.Settings ),{ levels : 2 } ) );

    if( appArgs.map.verbosity === 0 && appArgs.map.usingBeep === undefined )
    tester.settings.usingBeep = 0;
  }

  tester._appArgsApplied = appArgs;

  tester.path = appArgs.subject || _.pathCurrent();
  tester.path = _.pathJoin( _.pathCurrent(),tester.path );

  if( _.numberIs( tester.settings.verbosity ) )
  tester.verbosity = tester.settings.verbosity;

  tester.appArgs = appArgs;
  return appArgs;
}

//

function scenarioHelp()
{
  var tester = this;

  tester.scenarioScenariosList();
  tester.scenarioOptionsList();

}

//

function scenarioScenariosList()
{
  var tester = this;
  var logger = tester.logger;

  // _.assert( tester.settings.scenario === 'scenarios.list' );

  var strOptions =
  {
    levels : 3,
    wrap : 0,
    stringWrapper : '',
    multiline : 1
  };

  logger.log( 'Scenarios :\n',_.toStr( tester.scenariosHelpMap,strOptions ),'\n' );

}

//

function scenarioOptionsList()
{
  var tester = this;
  var logger = tester.logger;

  // _.assert( tester.settings.scenario === 'options.list' );

  var optionsList =
  {
    scenario : 'Name of scenario to launch. To get scenarios list use scenario : "scenarios.list".',
    sanitareTime : 'Delay before run of the next test suite.',
    usingBeep : 'Make beep sound after testing completion.',
    routine : 'Name of only test routine to execute.',
    fails : 'Maximum number of fails allowed before shutting down testing.',
    silencing : 'Enables catching of console output that occures during test run.',
    testRoutineTimeOut : 'Limits the time that each test routine can work. If execution of routine takes too long time then timeOut error will be thrown.',
    concurrent : 'Runs test suite in parallel with other test suites.',
    verbosity : 'Level of details in tester output. Zero for nothing, one for single line report, nine for maximum verbosity.',
    importanceOfNegative : 'Increase verbosity of test checks which fails.'
  }

  var strOptions =
  {
    levels : 3,
    wrap : 0,
    stringWrapper : '',
    multiline : 1
  };

  logger.log( 'Tester options' );
  logger.log( _.toStr( optionsList, strOptions ),'\n' );
}

//

function scenarioSuitesList()
{
  var tester = this;
  var logger = tester.logger;

  _.assert( tester.settings.scenario === 'suites.list' );

  tester.includeTestsFrom( tester.path );

  tester.testsListPrint( tester.testsFilterOut() );

}

// --
// run
// --

function _testAllAct()
{
  var tester = this;

  _.assert( arguments.length === 0 );

  var suites = tester.testsFilterOut( wTests );

  tester._testingBegin( suites );

  for( var t in suites )
  {
    tester._testAct( t );
  }

  wTestSuite._suiteCon
  .doThen( function() {
    if( tester._reportIsPositive() )
    return _.timeOut( tester.settings.sanitareTime );
  })
  .doThen( function()
  {
    return tester._testingEnd();
  });

  return wTestSuite._suiteCon.split();
}

//

var testAll = _.timeReadyJoin( undefined,_testAllAct );

//

function _testAct()
{
  var tester = this;

  _.assert( this === Self );

  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var _suite = arguments[ a ];
    var suite = wTestSuite.instanceByName( _suite );

    _.assert( suite instanceof wTestSuite,'Test suite',_suite,'was not found' );
    _.assert( _.strIsNotEmpty( suite.name ),'Test suite should has ( name )"' );
    _.assert( _.objectIs( suite.tests ),'Test suite should has map with test routines ( tests ), but "' + suite.name + '" does not have such map' );

    if( !suite.enabled )
    continue;

    suite._testSuiteRunLater();
  }

}

//

function _test()
{
  var tester = this;

  _.assert( this === Self );

  if( arguments.length === 0 )
  return tester._testAllAct();

  var suites = tester.testsFilterOut( arguments );

  tester._testingBegin( suites );

  tester._testAct.apply( tester,_.mapVals( suites ) );

  return wTestSuite._suiteCon
  .doThen( function() {
    if( tester._reportIsPositive() )
    return _.timeOut( tester.settings.sanitareTime );
  })
  .split( function()
  {
    return tester._testingEnd();
  });
}

//

var test = _.timeReadyJoin( undefined,_test );

//

function _testingBegin( suites )
{
  var tester = this;
  var logger = tester.logger;
  var firstSuite = _.mapFirstPair( suites )[ 1 ];

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.numberIs( tester.verbosity ) );
  _.assert( _.mapIs( suites ) );

  tester.appArgsApply();
  tester._registerExitHandler();

  if( !tester.appArgs.map )
  tester.appArgs.map = Object.create( null );

  logger.begin({ verbosity : -4 });
  logger.log( 'Tester Settings :' );
  logger.log( tester.settings );
  logger.log( '' );
  logger.end({ verbosity : -4 });

  logger.begin({ verbosity : -3 });

  if( suites !== undefined )
  {
    logger.logUp( 'Launching several ( ' + _.entityLength( suites ) + ' ) test suites ..' );
    tester.testsListPrint( suites );
  }
  else
  {
    debugger;
    logger.logUp( 'Launching all known ( ' + _.entityLength( wTests ) + ' ) test suites ..' );
    tester.testsListPrint( suites );
  }

  logger.log();
  logger.end({ verbosity : -3 });

  tester._cancelCon.cancel();

  tester._reportForm();

}

//

function _testingEnd()
{
  var tester = this;
  var logger = tester.logger || _global.logger;
  var ok = tester._reportIsPositive();

  if( tester.settings.usingBeep )
  _.beep();

  if( !ok && !_.appExitCode() )
  {
    if( tester.settings.usingBeep )
    _.beep();
    _.appExitCode( -1 );
  }

  var msg = tester._reportToStr();

  logger.begin({ verbosity : -2 });

  logger.begin({ 'connotation' : ok ? 'positive' : 'negative' });
  logger.log( msg );
  logger.end({ verbosity : -2 });

  logger.begin({ verbosity : -1 });
  var msg = 'Tester .. ' + ( ok ? 'ok' : 'failed' );
  logger.logDown( msg );
  logger.end({ 'connotation' : ok ? 'positive' : 'negative' });
  logger.end({ verbosity : -1 });

  /* */

  logger.verbosityPop();

  _.assert( logger._hasOutput( console,{ deep : 0, ignoringUnbar : 0 } ), 'Logger of the tester does not have console in outputs.' );

  debugger;
  if( !ok )
  _.timeOut( 100,function()
  {
    _.appExit();
  });

}

//

function testsFilterOut( suites )
{
  var tester = this;
  var logger = tester.logger;
  var suites = suites || wTests;

  if( _.arrayLike( suites ) )
  {
    var _suites = Object.create( null );
    for( var s = 0 ; s < suites.length ; s++ )
    {
      var suite = suites[ s ];
      if( _.strIs( suite ) )
      _suites[ suite ] = suite;
      else if( suite instanceof wTestSuite )
      _suites[ suite.name ] = suite;
      else _.assert( 0,'not tested' );
    }
    suites = _suites;
  }

  _.assert( arguments.length === 0 || arguments.length === 1,'expects none or single argument, but got',arguments.length );
  _.assert( _.objectIs( suites ) );

  var suites = _.entityFilter( suites,function( suite )
  {
    if( _.strIs( suite ) )
    {
      if( !wTests[ suite ] )
      throw _.err( 'Tester : test suite',suite,'not found' );
      suite = wTests[ suite ];
    }
    if( suite.abstract )
    return;
    // if( suite.enabled !== undefined && !suite.enabled )
    // return;
    return suite;
  });

  return suites;
}

//

function testsListPrint( suites )
{
  var tester = this;
  var logger = tester.logger;
  var suites = suites || wTests;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.each( suites,function( suite,k )
  {
    if( suite.enabled )
    logger.log( suite.suiteFileLocation, '-', ( suite.enabled ? 'enabled' : 'disabled' ) );
  });

  _.each( suites,function( suite,k )
  {
    if( !suite.enabled )
    logger.log( suite.suiteFileLocation, '-', ( suite.enabled ? 'enabled' : 'disabled' ) );
  });

  // logger.log( _.entitySelect( _.entityVals( suites ),'*.suiteFileLocation' ).join( '\n' ) );

  var l = _.entityLength( suites );

  logger.log( l, l > 1 ? 'test suites' : 'test suite' );

}

// --
// etc
// --

function _reportForm()
{
  var tester = this;
  var report = tester.report = Object.create( null );

  report.errorsArray = [];
  // report.includeFails = [];

  report.testCheckPasses = 0;
  report.testCheckFails = 0;

  report.testCasePasses = 0;
  report.testCaseFails = 0;
  report.testCaseNumber = 0;

  report.testRoutinePasses = 0;
  report.testRoutineFails = 0;

  report.testSuitePasses = 0;
  report.testSuiteFailes = 0;

  Object.preventExtensions( report );

}

//

function _reportToStr()
{
  var tester = this;
  var appExitCode = _.appExitCode();
  var report = tester.report;
  var msg = '';

  if( appExitCode !== undefined && appExitCode !== 0 )
  msg = 'ExitCode : ' + appExitCode + '\n';

  if( report.errorsArray.length )
  msg += 'Thrown ' + ( report.errorsArray.length ) + ' error(s)\n';

  msg += 'Passed test checks ' + ( report.testCheckPasses ) + ' / ' + ( report.testCheckPasses + report.testCheckFails ) + '\n';
  msg += 'Passed test cases ' + ( report.testCasePasses ) + ' / ' + ( report.testCasePasses + report.testCaseFails ) + '\n';
  msg += 'Passed test routines ' + ( report.testRoutinePasses ) + ' / ' + ( report.testRoutinePasses + report.testRoutineFails ) + '\n';
  msg += 'Passed test suites ' + ( report.testSuitePasses ) + ' / ' + ( report.testSuitePasses + report.testSuiteFailes ) + '';

  return msg;
}

//

function _reportIsPositive()
{
  var tester = this;
  var report = tester.report;

  var appExitCode = _.appExitCode();
  if( appExitCode !== undefined && appExitCode !== 0 )
  return false;

  if( report.testCheckFails !== 0 )
  return false;

  if( !( report.testCheckPasses > 0 ) )
  return false;

  if( report.testCaseFails !== 0 )
  return false;

  if( report.errorsArray.length )
  return false;

  if( tester.includeFails.length )
  return false;

  return true;
}

//

function _verbositySet( src )
{
  var tester = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( !_.numberIsNotNan( src ) )
  src = 0;

  tester[ symbolForVerbosity ] = src;

  if( src !== null )
  if( tester.logger )
  tester.logger.verbosity = src;

}

//

function _canContinue()
{
  var tester = this;

  if( tester.settings.fails > 0 )
  if( tester.settings.fails <= tester.report.testCheckFails )
  return false;

  return true;
}

//

function cancel( err )
{
  var tester = this;
  tester._cancelCon.error( _.err( err ) );
}

//

function _outcomeConsider( outcome )
{
  var tester = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( tester === Self );

  if( outcome )
  {
    tester.report.testCheckPasses += 1;
  }
  else
  {
    tester.report.testCheckFails += 1;
  }

}

//

function _exceptionConsider( err )
{
  var tester = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( tester === Self );

  err = _.errLogOnce( err );

  tester.report.errorsArray.push( err );
}

//

function _testCaseConsider( outcome )
{
  var tester = this;
  var report = tester.report;

  if( outcome )
  {
    report.testCasePasses += 1;
  }
  else
  {
    report.testCaseFails += 1;
    // console.log( 'report.testCaseFails += 1' );
    // debugger;
  }

}

// --
// report formatter
// --

function loggerToBook( o )
{

  if( !o )
  o = {};

  o.logger = o.logger || _.Tester.logger;

  _.routineOptions( loggerToBook,o );

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( o.logger instanceof wPrinterToJs );

  var data = o.logger.outputData;
  var routines = _.entitySearch({ src : data, ins : 'routine', searchingValue : 0, returnParent : 1, searchingSubstring : 0 });
  logger.log( _.toStr( routines,{ levels : 1 } ) );

  /* */

  var routineHead;
  routines = _.entityFilter( routines, function( routine,k )
  {
    routine.folderPath = _.pathDir( k );
    routine.itemsPath = _.pathDir( routine.folderPath );
    routine.itemsData = _.entitySelect( data,routine.itemsPath );

    if( routine.tail )
    {
      routineHead.data.report = [ routine ];
      _.mapSupplement( routineHead.attributes,_.mapBut( routine,{ text : 0 } ) );
      return;
    }

    /* checks */

    debugger;
    var checks = _.entitySearch
    ({
      src : routine,
      ins : 'check',
      searchingValue : 0,
      searchingSubstring : 0,
      returnParent : 1,
    });

    var routineMore = [];
    checks = _.entityFilter( checks, function( acheck,k )
    {
      if( !acheck.text )
      return;
      if( !acheck.tail )
      {
        routineMore.push( acheck );
        return;
      }

      acheck.checkPath = _.pathDir( k );
      var result = Object.create( null );
      result.data = acheck;
      debugger;
      result.text = acheck.check + ' # '+ acheck.checkIndex;
      result.attributes = _.mapBut( acheck,{ text : 0 } );

      result.kind = 'terminal';
      result.data.report = routineMore;
      routineMore = [];
      return result;
    });

    checks = _.entityVals( checks );

    /* routine */

    var result = Object.create( null );
    result.kind = 'branch';
    result.data = routine;
    result.text = routine.routine;
    result.elements = checks;
    result.attributes = _.mapBut( routine,{ text : 0 } );

    routineHead = result;
    return result;
  });

  /* */

  logger.log( _.toStr( routines,{ levels : 1 } ) );
  routines = _.entityVals( routines );

  /* */

  function handlePageGet( node )
  {
    if( !node.data )
    return '-';
    var result = _.entitySelect( node.data.report,'*.text' );

    if( node.data.check )
    result = result.join( '\n' ) + '\n' + node.data.text;
    else if( node.data.routine )
    result = node.data.text + '\n' + _.entitySelect( node.elements,'*.data.text' ).join( '\n' ) + '\n' + result.join( '\n' );

    return result;
  }

  /* */

  var book = new wHiBook({ targetDom : _.domTotalPanelMake().targetDom, onPageGet : handlePageGet });
  book.form();
  book.tree.treeApply({ elements : routines });

}

loggerToBook.defaults =
{
  logger : null,
}

//

function bookExperiment()
{

  if( 0 )
  _.timeReady( function()
  {

    // debugger;
    Self.verbosity = 0;
    //Self.logger = wPrinterToJs({ coloring : 0 });

    // _.Tester.test( 'Logger other test','Consequence','FileProvider.Extract' )
    _.Tester.test( 'FileProvider.Extract' )
    .doThen( function()
    {
      debugger;
      if( Self.logger )
      logger.log( _.toStr( Self.logger.outputData,{ levels : 5 } ) );
      debugger;
    });

  });

}

// --
// var
// --

var symbolForVerbosity = Symbol.for( 'verbosity' );

var SettingsOfTester =
{

  scenario : 'test',
  sanitareTime : 1000,

  usingBeep : 1,

  routine : null,
  fails : null,

}

var SettingsOfSuite =
{

  testRoutineTimeOut : null,
  concurrent : null,

  platforms : [ 'default' ],

  verbosity : null,
  importanceOfDetails : null,
  importanceOfNegative : null,

  routine : null,
  silencing : null,

}

var Settings = _.mapExtend( null,SettingsOfTester,SettingsOfSuite );

var scenariosHelpMap =
{
  'test' : 'run tests, default scenario',
  'help' : 'get help',
  'options.list' : 'list available options',
  'scenarios.list' : 'list available scenarios',
  'suites.list' : 'list available suites',
}

var scenariosActionMap =
{
  'test' : '',
  'help' : 'scenarioHelp',
  'scenarios.list' : 'scenarioScenariosList',
  'options.list' : 'scenarioOptionsList',
  'suites.list' : 'scenarioSuitesList',
}

var Forbids =
{

  sanitareTime : 'sanitareTime',
  testRoutineTimeOut : 'testRoutineTimeOut',

  importanceOfDetails : 'importanceOfDetails',
  importanceOfNegative : 'importanceOfNegative',

  concurrent : 'concurrent',
  silencing : 'silencing',
  scenario : 'scenario',
  routine : 'routine',
  fails : 'fails',
  usingBeep : 'usingBeep',

}

var Accessors =
{
  verbosity : 'verbosity',
}

// --
// define class
// --

var Self =
{

  // exec

  exec : exec,
  _registerExitHandler : _registerExitHandler,
  _includeTestsFrom : _includeTestsFrom,
  includeTestsFrom : includeTestsFrom,
  appArgsApply : appArgsApply,

  scenarioHelp : scenarioHelp,
  scenarioScenariosList : scenarioScenariosList,
  scenarioOptionsList : scenarioOptionsList,
  scenarioSuitesList : scenarioSuitesList,


  // run

  _testAllAct : _testAllAct,
  testAll : testAll,

  _testAct : _testAct,
  _test : _test,
  test : test,

  _testingBegin : _testingBegin,
  _testingEnd : _testingEnd,

  testsFilterOut : testsFilterOut,
  testsListPrint : testsListPrint,


  // etc

  _reportForm : _reportForm,
  _reportToStr : _reportToStr,
  _reportIsPositive : _reportIsPositive,

  _verbositySet : _verbositySet,
  _canContinue : _canContinue,
  cancel : cancel,

  _outcomeConsider : _outcomeConsider,
  _exceptionConsider : _exceptionConsider,
  _testCaseConsider : _testCaseConsider,


  // report formatter

  loggerToBook : loggerToBook,
  bookExperiment : bookExperiment,


  // var

  SettingsOfTester : SettingsOfTester,
  SettingsOfSuite : SettingsOfSuite,
  Settings : Settings,

  settings : Object.create( null ),

  logger : new _.Logger({ name : 'LoggerForTesting' }),
  _cancelCon : new _.Consequence(),

  activeSuites : [],
  includeFails : [],
  report : null,

  scenariosHelpMap : scenariosHelpMap,
  scenariosActionMap : scenariosActionMap,

  sourceFileLocation : sourceFileLocation,
  sourceFileStack : sourceFileStack,

  _isFullImplementation : 1,
  _registerExitHandlerDone : 0,

  _defaultVerbosity : 2,
  verbosity : 2,

  _bar : null,
  _appArgsApplied : null,
  path : null,
  appArgs : null,

  constructor : function wTester(){},

}

//

_.accessorForbid( Self,Forbids )

_.accessor
({
  object : Self,
  prime : 0,
  names : Accessors,
});

//

Object.preventExtensions( Self );
_.assert( !_realGlobal_.wTester );
_realGlobal_.wTester = _.Tester = Self;

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
