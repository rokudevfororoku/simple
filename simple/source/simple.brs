' ********************************************************************
' **  Aplicacion simple para roku
' **  Para mas informacion visita http://fororoku.com/foro
' ********************************************************************

Sub Main()
    ' esta es la informacion de nuestro video
    ' editar la url para que refleje el video disponible
    ' en nuestro servidor web 
    item = {   ContentType:"movie"
               SDPosterUrl:"file://pkg:/imagenes/poster_bunny_small.jpg"
               HDPosterUrl:"file://pkg:/imagenes/poster_bunny_small.jpg"
               IsHD:false
               HDBranded:false
               ShortDescriptionLine1:"Big Buck Bunny"
               ShortDescriptionLine2:""
               Description:"Big Buck Bunny es nuestro video localizado en el servidor web configurado en nuestra computadora."
               Rating:"AA"
               StarRating:80
               Length:600
               Categories:["Animacion","Infantil"]
               Title:"Big Buck Bunny"
               urls:["http://10.0.0.129/roku/videos/cortos/big_buck_bunny.mov"]
               bitrates:[0]
               qualities:["SD"]
               streamformat:"mp4"    
            }
    'inicializamos los atributos del tema como logo, colores, etc. 
    initTheme()

    'creamos una pantalla vacia para que la aplicacion no salga
    'de regreso al menu principal del roku.
    screenFacade = CreateObject("roPosterScreen")
    screenFacade.show()

    ' mostrar la pantalla del poster
    showSpringboardScreen(item) 
    
    'salir
    screenFacade.showMessage("")
    sleep(25)
End Sub

'*************************************************************
'** Atributos configurables para la presentacion
'** cabecera, logo, etc.
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangPrimaryLogoOffsetSD_X = "72"
    theme.OverhangPrimaryLogoOffsetSD_Y = "13" 
    theme.OverhangSliceSD = "pkg:/imagenes/Overhang_BackgroundSlice_SD.png"
    theme.OverhangPrimaryLogoSD  = "pkg:/imagenes/logo_SD.png"

    theme.OverhangPrimaryLogoOffsetHD_X = "123"
    theme.OverhangPrimaryLogoOffsetHD_Y = "18" 
    theme.OverhangSliceHD = "pkg:/imagenes/Overhang_BackgroundSlice_HD.png"
    theme.OverhangPrimaryLogoHD  = "pkg:/imagenes/logo_HD.png"
    
    theme.SubtitleColor = "#dc00dc"
    
    app.SetTheme(theme)

End Sub


'*************************************************************
'** showSpringboardScreen()
'** pantalla del poster
'*************************************************************

Function showSpringboardScreen(item as object) As Boolean
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")

    print "showSpringboardScreen"
    
    screen.SetMessagePort(port)
    screen.AllowUpdates(false)
    if item <> invalid and type(item) = "roAssociativeArray"
        screen.SetContent(item)
        videoclip = CreateObject("roAssociativeArray")
        videoclip.StreamBitrates = item.bitrates
        videoclip.StreamUrls = item.urls
        videoclip.StreamQualities = item.qualities
        videoclip.StreamFormat = item.streamformat
        videoclip.Title = item.Title      
    endif

    screen.SetDescriptionStyle("movie") 'audio, movie, video, generic
                                        ' generic+episode=4x3,
    screen.ClearButtons()
    screen.AddButton(1,"Reproducir")
    screen.AddButton(2,"Salir")
    'screen.SetStaticRatingEnabled(false)
    screen.AllowUpdates(true)
    screen.Show()

    downKey=3
    selectKey=6
    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roSpringboardScreenEvent"
            if msg.isScreenClosed()
                print "Pantalla cerrada"
                exit while                
            else if msg.isButtonPressed()
                    print "Boton presionado: "; msg.GetIndex(); " " msg.GetData()
                    if msg.GetIndex() = 1                         
                         displayVideo(videoclip)
                    else if msg.GetIndex() = 2
                         return true
                    endif
            else
                print "Evento desconocido: "; msg.GetType(); " mensaje: "; msg.GetMessage()
            endif
        else 
            print "equivocado.... tipo=";msg.GetType(); " mensaje: "; msg.GetMessage()
        endif
    end while


    return true
End Function


'*************************************************************
'** displayVideo()
'** esta funcion reproduce el video
'*************************************************************
Function displayVideo(videoclip as object)
    print "Reproduciendo video: "
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)    
    video.SetContent(videoclip)    
    video.show()

    lastSavedPos   = 0
    statusInterval = 10 

    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then 
                print "Cerrando pantalla de video"
                exit while
            else if msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()
                if nowpos > 10000
                    
                end if
                if nowpos > 0
                    if abs(nowpos - lastSavedPos) > statusInterval
                        lastSavedPos = nowpos
                    end if
                end if
            else if msg.isRequestFailed()
                print "Falla en la reproduccion: "; msg.GetMessage()
            else
                print "Evento desconocido: "; msg.GetType(); " mensaje: "; msg.GetMessage()
            endif
        end if
    end while
End Function
