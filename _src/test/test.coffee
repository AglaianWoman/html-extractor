HTMLExtractor = require( "../lib/html_extractor" )
testData = require( "./test_data" )

request = require( "request" )

should = require( "should" )

_extractor = new HTMLExtractor( true )

getHTML = ( link, cb )->
	request.get link, ( err, data )->
		if err
			throw err
		cb( data.body )
		return
	return

describe 'HTML-dispatch-TEST', ->

	before ( done )->
		done()
		return

	after ( done )->
		done()
		return



	describe 'TEST Parser', ->
		it "Test tcs.de HTML", ( done )->

			_extractor.extract testData.html[ 0 ], ( err, data )->
				if err
					throw err

				should.exist( data.meta )
				should.exist( data.meta.title )
				data.meta.title.should.equal("TCS: Team Centric Software GmbH & Co. KG")
				should.exist( data.body )
				data.body.should.not.be.empty

				data.body.should.not.containEql( "$('#contactform')" )
				data.body.should.not.containEql( ".testcssselector" )
				data.body.should.not.containEql( "</" )
				#console.log data.meta, data.body.length, data.h1
				done()
				return
			return
		
		it "Test spiegel.de HTML", ( done )->

			_extractor.extract testData.html[ 1 ], ( err, data )->
				if err
					throw err

				should.exist( data.meta )
				should.exist( data.meta.title )
				data.meta.title.should.equal("SPIEGEL ONLINE - Nachrichten")
				should.exist( data.body )
				data.body.should.not.containEql( "</" )
				data.body.should.not.be.empty
				
				#console.log data.meta, data.body.length, data.h1
				done()
				return
			return
		return
	
	describe 'Test Request', ->
		
		it "test get HTML", ( done )->

			getHTML testData.links[ 0 ], ( html )->
				html.should.be.a.String()
				html.length.should.be.above( 0 )
				html.should.containEql( "Team Centric Software GmbH" )
				done()
				return
			return

	describe 'Test Parser with multiple pages', ->
		_count = process.env.COUNT or 5
		for _link, idx in testData.links[ 0.._count ]
			do( _link )->
				it "#{ idx }: Parse '#{ _link }'", ( done )->

					getHTML _link, ( html )->

						_extractor.extract html, ( err, data )->
							if err
								throw err
							should.exist( data.meta )
							should.exist( data.meta.title )
							should.exist( data.body )
							data.body.should.not.containEql( "</" )
							data.body.should.not.be.empty
							
							#console.log "\nHEADER of #{ _link }\n", data.meta.title, "\n", JSON.stringify( data.meta, true, 2 ), "\n", JSON.stringify( data.h1, true, 2 )

							done()
							return
						return
					return

		return

	describe 'Test reducing', ->
		for _reduce, idx in testData.reduce
			do( _reduce, idx )->
				it "#{ idx }: Reduced parse '#{ _reduce.url }'", ( done )->
					getHTML _reduce.url, ( html )->

						_extractor.extract html, _reduce.reduced, ( err, data )->
							if err
								throw err
							should.exist( data.meta )
							should.exist( data.meta.title )
							should.exist( data.body )
							data.body.should.not.be.empty
							switch idx
								when 0
									data.body.should.be.instanceof( String )
									data.body.should.not.containEql( "</" )
									data.body.should.not.containEql "EDV-Downloadbereich"
									data.body.should.not.containEql "Spitalgasse 31"

									data.body.should.containEql "Herzlich willkommen im APO-Shop"
								when 1
									data.body.should.be.instanceof( String )
									data.body.should.not.containEql( "</" )
									data.body.should.not.containEql "Impressum"
									data.body.should.not.containEql "Haftungsausschluss"

									data.body.should.containEql "Geschäftsführung"
								
								when 2
									data.body.should.be.instanceof( Array )
									data.body.should.have.length( 11 )
									data.body[ 0 ].should.startWith "Dynamo DB"
							
							#console.log "\nBody of #{  _reduce.url }\n", data.body

							done()
							return
						return
					return
				return
			return
		return

	describe 'Issues', ->
		it "#1 Returned body contains html entities", ( done )->
			_html = '<body><p>&nbsp;HELLO!&nbsp;</p><h1>&nbsp;Headline &gt; &lt; &euro;&nbsp;&nbsp;&nbsp;...&nbsp;&nbsp;&nbsp;</h1></body>'
			_exp =
				meta: 
					title: ""
					description: ""
					keywords: []
				body: "HELLO! Headline > < € ..."
				h1: [  "Headline > < €   ..." ]

			_extractor.extract _html, ( err, data )->
				if err
					throw err
				should.exist( data )
				data.should.eql( _exp )
				done()
				return
			return

		return

		it "#3 str.replace is not a function when using reduce with list: true", ( done )->
			_html = '<body><p id="indexable">term one</p><p>non indexable content</p><p id="indexable">term&nbsp;&nbsp;&nbsp;two&nbsp;&nbsp;&nbsp;</p></body>'
			_exp =
				meta:
					title: ""
					description: ""
					keywords: []
				body: ["term one", "term   two"]
				h1: []
			_reduce =
				tag: "p"
				attr: "id"
				val: "indexable"
				list: true

			_extractor.extract _html, _reduce, ( err, data )->
				if err
					throw err
				should.exist( data )
				data.should.eql( _exp )
				done()
				return
			return

	
	return

	
