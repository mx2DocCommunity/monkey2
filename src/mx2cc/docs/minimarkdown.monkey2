
Namespace mx2.docs.minimarkdown

Class MarkdownConvertor

	Const CHAR_HASH:=35		'#
	Const CHAR_ESCAPE:=92	'\

	Method New( src:String )
	
		_src=src
		_lines=_src.Split( "~n" )
		
		For Local i:=0 Until _lines.Length
			_lines[i]=_lines[i].TrimEnd()
		Next
		
	End
	
	Method ToHtml:String()
	
		While Not AtEnd
		
			Local line:=NextLine()
		
			If line.StartsWith( "#" )
			
				EmitHeader( line )
			
			Else If line.StartsWith( "|" )
			
				EmitTable( line )
				
			Else If line.StartsWith( "*" )
			
				EmitList( line )
				
			Else If line.StartsWith( "```" )
			
				EmitCode( line )
				
			Else If line.StartsWith( "---" )
			
				Emit( "<hr>" )
				
			Else If line.StartsWith( "<" )
			
				Emit( line+"\" )
				
			Else If line
			
				If _lineNum>1 And _lines[_lineNum-2]=""
					Emit( "<p>"+Escape( line ) )
				Else
					Emit( Escape( line ) )
				Endif

			Else
			
'				If Not _buf.Empty And _buf.Top<>"<p>" Emit( "<p>" )
				
			Endif
				
'			Else 
			
'				If _buf.Empty Or _buf.Top="" Emit( "<p>" )
			
'				Emit( Escape( line ) )
			
'			Endif
			
		Wend
		
		Local html:=_buf.Join( "~n" )
		
		html=html.Replace( "\~n","" )
		
		Return html
	
	End

	Private
	
	Field _src:String
	Field _lines:String[]
	
	Field _lineNum:=0
	Field _buf:=New StringStack
	
	Property AtEnd:Bool()
		Return _lineNum>=_lines.Length
	End
	
	Method Emit( str:String )
		_buf.Push( str )
	End

	Method NextLine:String()
		Local line:=_lineNum>=0 And _lineNum<_lines.Length ? _lines[_lineNum] Else ""
		_lineNum+=1
		Return line
	End
	
	Method PrevLine:String()
		_lineNum-=1
		Local line:=_lineNum>=0 And _lineNum<_lines.Length ? _lines[_lineNum] Else ""
		Return line
	End
	
	Method Find:Int( str:String,chr:String,index:Int=0 )

		Repeat
			Local i:=str.Find( chr,index )
			If i=-1 Return str.Length
			If i=0 Or str[i-1]<>CHAR_ESCAPE Return i
			index=i+1
		Forever
		
		Return str.Length
	End
	
	Method ReplaceAll:String( str:String,find:String,rep:String,index:Int )
	
		Local i0:=index
		
		Repeat
		
			Local i1:=str.Find( find,i0 )
			If i1=-1 Exit
			
			str=str.Slice( 0,i1 )+rep+str.Slice( i1+find.Length )
			i0=i1+rep.Length
		
		Forever
		
		Return str
	End
	
	Method EscapeHtml:String( str:String )
	
		'str=str.Replace( "&","&amp;" )
		Local i0:=0
		Repeat
		
			Local i1:=str.Find( "&",i0 )
			If i1=-1 Exit

			Const tags:=New String[]( "nbsp;" )

			For Local tag:=Eachin tags
				If str.Slice( i1+1,i1+1+tag.Length )<>tag Continue
				i0=i1+1+tag.Length
				Exit
			Next
			If i0>i1 Continue
			
			Local r:="&amp;"
			str=str.Slice( 0,i1 )+r+str.Slice( i1+1 )
			i0=i1+r.Length
		Forever
		
		'str=str.Replace( "<","&lt;" )
		'str=str.Replace( ">","&gt;" )
		i0=0
		Repeat
		
			Local i1:=str.Find( "<",i0 )
			If i1=-1 
				str=ReplaceAll( str,">","&gt;",i0 )
				Exit
			Endif
			
			Local i2:=str.Find( ">",i1+1 )
			If i2=-1
				str=ReplaceAll( str,"<","&lt;",i0 )
				str=ReplaceAll( str,">","&gt;",i0 )
				Exit
			Endif
			
			Const tags:=New String[]( "a href=","/a" )
			
			For Local tag:=Eachin tags
				If str.Slice( i1+1,i1+1+tag.Length )<>tag Continue
				
				Local r:=str.Slice( i1+1,i2 )

				r=r.Replace( "\","\\" )
				r=r.Replace( "*","\*" )
				r=r.Replace( "_","\_" )
				r=r.Replace( "`","\`" )
				
				r="<"+r+">"

				str=str.Slice( 0,i1 )+r+str.Slice( i2+1 )
				i0=i1+r.Length
				Exit
			Next
			If i0>i1 Continue
			
			Local r:="&lt;"+str.Slice( i1+1,i2 )+"&gt;"
			str=str.Slice( 0,i1 )+r+str.Slice( i2+1 )
			i0=i1+r.Length
		Forever
			
		Return str
	End
	
	Method ConvertSpanTags:String( str:String,tag:String,ent:String )
	
		Local op:="<"+ent+">"
		Local cl:="</"+ent+">"
	
		Local i0:=0
		Repeat
		
			Local i1:=Find( str,tag,i0 )
			If i1=str.Length Return str
			
			Local i2:=Find( str,tag,i1+1 )
			If i2=str.Length Return str
			
			Local r:=op+str.Slice( i1+1,i2 )+cl
			
			str=str.Slice( 0,i1 )+r+str.Slice( i2+1 )
			i0=i1+r.Length
		
		Forever
		
		Return str
	End
	
	#rem
	Method ConvertSpanHtml:String( str:String )
	
		Local i0:=0
		Repeat

			Local i1:=Find( str,"[",i0 )
			If i1=str.Length Return str
			
			Local i2:=Find( str,"]",i1+1 )
			If i2=str.Length Return str

			Local is:=i1+1
			While is<i2 And IsAlpha( str[is] )
				is+=1
			Wend
			If is=i1+1
				i0=i2+1
				Continue
			End
			Local id:=str.Slice( i1+1,is )
			
			Local i3:=Find( str,"[/"+id+"]",i2+1 )
			If i3=str.Length 
				i0=i2+1
				Continue
			Endif
			
			Local args:=str.Slice( is,i2 )

			args=args.Replace( "\","\\" )
			args=args.Replace( "*","\*" )
			args=args.Replace( "_","\_" )
			args=args.Replace( "`","\`" )
			
			Local r:="<"+id+args+">"+str.Slice( i2+1,i3 )+"</"+id+">"
			
			str=str.Slice( 0,i1 )+r+str.Slice( i3+id.Length+3 )
			
			i0=i1+r.Length
			
		Forever
		
		Return str
	End
	
	Method ConvertSpanLinks:String( str:String )
	
		Local i0:=0

		Repeat
		
			Local i1:=Find( str,"[",i0 )
			If i1=str.Length Return str
			
			Local i2:=Find( str,"](",i1+1 )
			If i2=str.Length 
				i0=i1+1
				Continue
			Endif
			
			Local i3:=Find( str,")",i2+2 )
			If i3=str.Length
				i0=i2+2
				Continue
			Endif
			
			Local text:=str.Slice( i1+1,i2 )
			Local href:=str.Slice( i2+2,i3 )
			
			href=href.Replace( "\","\\" )
			href=href.Replace( "*","\*" )
			href=href.Replace( "_","\_" )
			href=href.Replace( "`","\`" )
			
			Local r:="<a href=~q"+href+"~q>"+text+"</a>"
			
			str=str.Slice( 0,i1 )+r+str.Slice( i3+1 )
			i0=i1+r.Length
			
		Forever
		
		Return str
	End
	#end
	
	Method ConvertEscapeChars:String( str:String )
	
		Local i0:=0

		Repeat
			Local i1:=str.Find( "\",i0 )
			If i1=-1 Or i1+1=str.Length  Return str
			str=str.Slice( 0,i1 )+str.Slice( i1+1 )
			i0=i1+1
		Forever
		
		Return str
	End
	
	Method Escape:String( str:String )
	
		str=EscapeHtml( str )
		
		'str=ConvertSpanHtml( str )
		'str=ConvertSpanLinks( str )
		
		str=ConvertSpanTags( str,"*","b" )
		str=ConvertSpanTags( str,"_","i" )
		str=ConvertSpanTags( str,"`","code" )
		
		str=ConvertEscapeChars( str )
		
		Return str
	End
	
	Method EmitHeader( line:String )

		Local i:=1
		While i<line.Length
			If line[i]<>CHAR_HASH Exit
			i+=1
		Wend
				
		Emit( "<h"+i+">" )
		Emit( Escape( line.Slice( i ).TrimStart() ) )
		Emit( "</h"+i+">" )
	End
	
	Method EmitTable( line:String )

		Local head:=line
		Local align:=NextLine()
				
		If Not align.StartsWith( "|" )
			Emit( Escape( head ) )
			PrevLine()
			Return
		Endif
			
		Local heads:=New StringStack
		Local aligns:=New StringStack
				
		Local i0:=1
		While i0<head.Length
			Local i1:=Find( head,"|",i0 )
			heads.Push( Escape( head.Slice( i0,i1 ).TrimStart() ) )
			i0=i1+1
		Wend
				
		i0=1
		While i0<align.Length
			Local i1:=Find( align,"|",i0 )
			Local t:=align.Slice( i0,i1 )
			If t.StartsWith( ":-" )
				If t.EndsWith( "-:" )
					aligns.Push( "center" )
				Else
					aligns.Push( "left" )
				Endif
			Else If t.EndsWith( "-:" )
				aligns.Push( "right" )
			Else
				aligns.Push( "center" )
			Endif
			i0=i1+1
		Wend
				
		While aligns.Length<heads.Length
			aligns.Push( "center" )
		Wend
				
		Emit( "<table>" )

		Emit( "<tr>" )
		For Local i:=0 Until heads.Length
			Emit( "<th style=~qtext-align:"+aligns[i]+"~q>"+heads[i]+"</th>" )
		Next
		Emit( "</tr>" )
				
		Repeat
			Local row:=NextLine()
			If Not row.StartsWith( "|" ) 
				PrevLine()
				Exit
			Endif
					
			Emit( "<tr>" )
			Local i0:=1,col:=0
			While i0<row.Length And col<heads.Length
				Local i1:=Find( row,"|",i0 )
				Emit( "<td style=~qtext-align:"+aligns[col]+"~q>"+Escape( row.Slice( i0,i1 ).TrimStart() )+"</td>" )
				i0=i1+1
				col+=1
			Wend
			Emit( "</tr>" )
		Forever
				
		Emit( "</table>" )
		
	End
	
	Method EmitList( line:String )
	
		Local kind:=line.Slice( 0,1 )
		
		Select kind
		Case "*" Emit( "<ul>" )
		Case "+" Emit( "<ol>" )
		End
		
		Repeat
		
			Emit( "<li>"+Escape( line.Slice( 1 ) )+"</li>" )
			
			If AtEnd Exit
		
			line=NextLine()
			If line.StartsWith( kind ) Continue
			
			PrevLine()
			Exit

		Forever
		
		Select kind
		Case "*" Emit( "</ul>" )
		Case "+" Emit( "</ol>" )
		End
	
	End
	
	Method EmitCode( line:String )
	
		Emit( "<pre><code>\" )
	
		While Not AtEnd
		
			line=NextLine()
			If line.StartsWith( "```" ) Exit
			
			Emit( EscapeHtml( line ) )
			
		Wend
		
		Emit( "</code></pre>" )
	
	End
	
End

Function MarkdownToHtml:String( markdown:String )

	Local convertor:=New MarkdownConvertor( markdown )
	
	Return convertor.ToHtml()

End
