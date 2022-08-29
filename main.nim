import math
import opengl, opengl/[glu, glut]



var playerX, playerY: float

proc drawPlayer() =
    glColor3f(1,1,0)
    glPointSize(8)
    glBegin(GL_POINTS)
    glVertex2f(playerX, playerY)
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

proc buttons(key:int8, x, y: cint) {.cdecl} =
    const keyA = 97
    const keyS = 115
    const keyD = 100
    const keyW = 119
    if key == keyA: playerX-=5
    if key == keyD: playerX+=5
    if key == keyS: playerY+=5
    if key == keyW: playerY-=5
    glutPostRedisplay()
    

proc display() {.cdecl} =
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    drawMap2D()
    drawPlayer()
    glutSwapBuffers()

proc init() =
    glClearColor(0.3, 0.3, 0.3, 0)
    gluOrtho2D(0,1024,512,0)
    playerX = 300
    playerY = 300

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