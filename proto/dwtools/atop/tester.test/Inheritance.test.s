( function _Inheritance_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{


  let _ = require( '../../Tools.s' );

  if( typeof _realGlobal_ === 'undefined' || !_realGlobal_.wTester || !_realGlobal_.wTester._isReal_ )
  require( '../tester/Main.mid.s' );

  _.include( 'wLogger' );
  _.include( 'wConsequence' );

}

var _global = _global_;
var _ = _global_.wTools;

//

function inherit( test )
{
  var routines = [];
  var childSuitName = 'childSuit';
  var firstParentName = 'parentSuit1';
  var secondParentName = 'parentSuit2';
  var checksCount = 0;

  var notTakingIntoAccount = { logger : _.Logger({ output : null }), concurrent : 1, takingIntoAccount : 0 };

  routines.push( test.name );

  // parent 1

  function test1()
  {
    var self = this;

    routines.push( test.name );

    test.case = 'check if child suit runs this test';
    test.identical( /*_.*/wTester.activeSuits[ 1 ].name, childSuitName );
    checksCount += test.checkCurrent()._checkIndex;
  }

  var ParentSuit1 =
  {
    name : firstParentName,
    abstract : 1,
    override : notTakingIntoAccount,
    silencing : 0,
    importanceOfDetails : 3,

    context :
    {
      parentValue1 : 1
    },

    tests :
    {
      test1 : test1
    },

  };

  wTestSuite( ParentSuit1 );

  // parent 2

  function test2()
  {
    var self = this;

    routines.push( test.name );

    test.case = 'check if child suit inherits tests, options, context from parent';
    var tests = _.mapOwnKeys( wTests[ childSuitName ].tests );
    test.identical( tests, [ 'test1', 'test2' ] );
    test.identical( wTests[ childSuitName ].abstract, 0 );

    test.identical( wTests[ childSuitName ].verbosity , wTests[ firstParentName ].verbosity );
    test.identical( wTests[ childSuitName ].importanceOfDetails , wTests[ firstParentName ].importanceOfDetails );
    test.identical( wTests[ childSuitName ].silencing , wTests[ firstParentName ].silencing );
    test.identical( wTests[ childSuitName ].importanceOfNegative , wTests[ secondParentName ].importanceOfNegative );
    test.identical( wTests[ childSuitName ].debug, wTests[ secondParentName ].debug );

    test.identical( self.parentValue1 , 1 );
    test.identical( self.parentValue2 , 2 );
    test.identical( self.childValue , 3 );

    checksCount += test.checkCurrent()._checkIndex;

  }

  var ParentSuit2 =
  {
    name : secondParentName,
    abstract : 1,
    debug : 1,
    override : notTakingIntoAccount,
    importanceOfNegative : 4,

    context :
    {
      parentValue2 : 2
    },

    tests :
    {
      test2 : test2
    },

  };

  wTestSuite( ParentSuit2 );

  // child

  var childSuit =
  {

    name : childSuitName,
    abstract : 0,
    override : notTakingIntoAccount,
    ignoringTesterOptions : 1,

    tests :
    {
    },

    context :
    {
      childValue : 3
    },

  }

  var suit = new wTestSuite( childSuit )
  .inherit( wTests[ firstParentName ] )
  .inherit( wTests[ secondParentName] );

  return suit.run()
  .doThen( function()
  {
    test.is( test.report.testCheckPasses > 9  );
    test.identical( test.report.testCheckFails, 0 );
    test.identical( routines.length, 3 );
    test.identical( _.mapOwnKeys( suit.tests ).length, 2 );
  })
}

//

var Proto =
{

  name : 'Tools/tester/Inheritance',
  silencing : 1,
  // enabled : 1,
  // verbosity : 5,

  tests :
  {
    inherit : inherit
  },

}

//

var Self = new wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
/*_.*/wTester.test( Self );

})();
