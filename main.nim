import math
import strformat
import opengl, opengl/[glu, glut]

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

proc drawRays2D() = 
    var 
        mx, my, mp: int
        xo, yo, rayAngle, rayX, rayY: float
        depth {.volatile}: int
    rayAngle = playerAngle
    for ray in 0 ..< 1:
        depth = 0
        var aTan:float = -1 / tan(rayAngle)
        if rayAngle > PI:
            rayY = ((playerY.int shr 6) shl 6).toFloat - 0.0001
            rayX = (playerY - rayY) * aTan + playerX
            yo = -64
            xo = -yo * aTan
        if rayAngle < PI:
            rayY = ((playerY.int shr 6) shl 6).toFloat + 64.0
            rayX = (playerY - rayY) * aTan + playerX
            yo = 64
            xo = -yo * aTan            
        if rayAngle == 0 or rayAngle == PI:
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
                else:
                    rayX += xo
                    rayY += yo
                    inc depth
            else:
                rayX += xo
                rayY += yo
                inc depth
    glColor3f(0,1,0)
    glLineWidth(1)
    glBegin(GL_LINES)
    glVertex2f(playerX, playerY)
    glvertex2f(rayX, rayY)
    glEnd()

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
    drawPlayer()
    drawRays2D()
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