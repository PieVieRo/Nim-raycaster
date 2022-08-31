import math
import strformat
import opengl, opengl/[glu, glut]

const
    P2:float = PI/2
    P3:float = 3.0*P2
    DR:float = 0.0174532925 # one degree in radians

var 
    playerX, playerY: float
    playerDX, playerDY: float
    playerAngle: float

proc drawPlayer() =
    glColor3f(1,1,0)
    glPointSize(8)
    glBegin(GL_POINTS)
    glVertex2f(playerX, playerY)
    glEnd()

    glLineWidth(3)
    glBegin(GL_LINES)
    glVertex2f(playerX, playerY)
    glVertex2f(playerX+playerDX*5, playerY+playerDY*5)
    glEnd()


var
    mapX:int = 8 
    mapY:int = 8
    mapS:int = 64

var map = [
    1,1,1,1,1,1,1,1,
    1,0,1,0,0,0,0,1,
    1,0,1,0,0,0,0,1,
    1,0,1,0,0,0,0,1,
    1,0,0,0,0,0,0,1,
    1,0,0,0,0,1,0,1,
    1,0,0,0,0,0,0,1,
    1,1,1,1,1,1,1,1,
]

proc drawMap2D() =
    var x,y: int
    var xo,yo: GLint
    # FYI I tried doing it with for loops but it didn't work
    while y < mapY:
        while x < mapX:
            if map[y * mapX + x] == 1:
                glColor3f(1,1,1)
            else:
                glColor3f(0,0,0)
            xo = cast[GLint](x * mapS)
            yo = cast[GLint](y * mapS)
            glBegin(GL_QUADS)
            glVertex2i(xo + 1, yo + 1)
            glvertex2i(xo + 1, yo + cast[GLint](mapS) - 1)
            glVertex2i(xo + cast[GLint](mapS) - 1, yo + cast[GLint](mapS) - 1)
            glVertex2i(xo + cast[GLint](mapS) - 1, yo + 1)
            glEnd()
            inc x
        x = 0
        inc y

proc distance(ax:float, ay:float, bx:float, by:float, angle:float):float =
    return sqrt((bx-ax) * (bx-ax) + (by-ay) * (by-ay))


proc drawRays3D() = 
    var 
        mx, my, mp, depth: int
        xo, yo, rayAngle, rayX, rayY, disT: float

    rayAngle = playerAngle - DR * 30
    if rayAngle < 0:
        rayAngle += 2*PI
    if rayAngle > 2*PI:
        rayAngle -= 2*PI

    for ray in 0 ..< 60:

        # check horizontal lines
        depth = 0
        var
            disH:float = 100000000
            hx:float = playerX
            hy:float = playerY
        var aTan:float = -1 / tan(rayAngle)

        if rayAngle > PI: # check down
            rayY = ((playerY.int shr 6) shl 6).toFloat - 0.0001
            rayX = (playerY - rayY) * aTan + playerX
            yo = -64
            xo = -yo * aTan
        if rayAngle < PI: # check up
            rayY = ((playerY.int shr 6) shl 6).toFloat + 64.0
            rayX = (playerY - rayY) * aTan + playerX
            yo = 64
            xo = -yo * aTan            
        if rayAngle == 0 or rayAngle == PI: # check left and right
            rayX = playerX
            rayY = playerY
            depth = 8

        while depth < 8:
            mx = rayX.int shr 6
            my = rayY.int shr 6
            mp = my * mapX + mx

            if mp < mapX * mapY and mp > 0:
                if map[mp]==1:
                    depth = 8
                    hx=rayX
                    hy=rayY
                    disH=distance(playerX,playerY,hx,hy,rayAngle)
                else:
                    rayX += xo
                    rayY += yo
                    inc depth
            else:
                rayX += xo
                rayY += yo
                inc depth

      # check vertical lines
        depth = 0
        var
            disV:float = 100000000
            vx:float = playerX
            vy:float = playerY
        var nTan:float = -tan(rayAngle)

        if rayAngle > P2 and rayAngle < P3: # check left
            rayX = ((playerX.int shr 6) shl 6).toFloat - 0.0001
            rayY = (playerX - rayX) * nTan + playerY
            xo = -64
            yo = -xo * nTan
        if rayAngle < P2 or rayAngle > P3: # check right
            rayX = ((playerX.int shr 6) shl 6).toFloat + 64.0
            rayY = (playerX - rayX) * nTan + playerY
            xo = 64
            yo = -xo * nTan            
        if rayAngle == 0 or rayAngle == PI: # check up and down
            rayX = playerX
            rayY = playerY
            depth = 8

        while depth < 8:
            mx = rayX.int shr 6
            my = rayY.int shr 6
            mp = my * mapX + mx

            if mp < mapX * mapY and mp > 0:
                if map[mp]==1:
                    depth = 8
                    vx=rayX
                    vy=rayY
                    disV=distance(playerX,playerY,vx,vy,rayAngle)
                else:
                    rayX += xo
                    rayY += yo
                    inc depth
            else:
                rayX += xo
                rayY += yo
                inc depth

        if disV < disH:
            rayX = vx
            rayY = vy
            disT = disV
            glColor3f(0.9,0,0)
        else:
            rayX = hx
            rayY = hy
            disT = disH
            glColor3f(0.7,0,0)
            
        glLineWidth(3)
        glBegin(GL_LINES)
        glVertex2f(playerX, playerY)
        glvertex2f(rayX, rayY)
        glEnd()

        # draw 3D walls
        var ca:float = playerAngle - rayAngle
        if ca < 0:
            ca += 2*PI
        if ca > 2*PI:
            ca -= 2*PI
        disT = disT*cos(ca)
        var 
            lineHeight:float =(mapS*320).toFloat / disT
            lineOffset:float = 160 - lineHeight/2
        if lineHeight > 320: lineHeight = 320
        glLineWidth(8)
        glBegin(GL_LINES)
        glVertex2i((ray*8+530).GLint, lineOffset.GLint)
        glVertex2i((ray*8+530).GLint, (lineHeight+lineOffset).GLint)
        glEnd()

        rayAngle += DR
        if rayAngle < 0:
            rayAngle += 2*PI
        if rayAngle > 2*PI:
            rayAngle -= 2*PI

proc buttons(key:int8, x, y: cint) {.cdecl} =
    const 
        keyA = 97
        keyS = 115
        keyD = 100
        keyW = 119

    if key == keyA: 
        playerAngle-=0.1
        if playerAngle < 0: playerAngle+=2*PI
        playerDX = cos(playerAngle)*5
        playerDY = sin(playerAngle)*5
    if key == keyD: 
        playerAngle+=0.1
        if playerAngle > 2*PI: playerAngle-=2*PI
        playerDX = cos(playerAngle)*5
        playerDY = sin(playerAngle)*5
    if key == keyW: 
        playerX += playerDX
        playerY += playerDY
    if key == keyS: 
        playerX -= playerDX
        playerY -= playerDY
    glutPostRedisplay()
    

proc display() {.cdecl} =
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    drawMap2D()
    drawRays3D()
    drawPlayer()
    glutSwapBuffers()

proc init() =
    glClearColor(0.3, 0.3, 0.3, 0)
    gluOrtho2D(0,1024,512,0)
    playerX = 300
    playerY = 300
    playerDX = cos(playerAngle)*5
    playerDY = sin(playerAngle)*5

var argc: cint = 0
glutInit(addr argc, nil)
glutInitDisplayMode(GLUT_DOUBLE or GLUT_RGBA)
glutInitWindowSize(1024, 512)
discard glutCreateWindow("test")
loadExtensions()
init()
glutDisplayFunc(display)
glutKeyboardFunc(buttons)
glutMainLoop()