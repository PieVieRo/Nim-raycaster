#include <stdio.h>
#include <math.h>
#define PI 3.14159265359

void calculateRays(float playerX, float playerY, float playerAngle, int mapX, int mapY, int map[], float rayLocation[]) {
    int ray, mx, my, mp;
    float xo, yo, rayAngle;
    int volatile depth;
    rayAngle = playerAngle;
    for(ray = 0; ray < 1; ray++) {
        // checking horizontal lines
        depth = 0;
        float aTan = -1 / tan(rayAngle);
        if (rayAngle > PI) { 
            rayLocation[1] = (((int)playerY>>6)<<6) - 0.0001;
            rayLocation[0] = (playerY - rayLocation[1]) * aTan + playerX;
            yo = -64;
            xo = -yo * aTan;
            printf("up %f %f %i %i %f\n", rayLocation[0], rayLocation[1], yo, xo, aTan);
        }
        if (rayAngle < PI) { 
            rayLocation[1] = (((int)playerY>>6)<<6) + 64;
            rayLocation[0] = (playerY - rayLocation[1]) * aTan + playerX;
            yo = 64;
            xo = -yo * aTan;
            printf("down %f %f %i %i %f\n", rayLocation[0], rayLocation[1], yo, xo, aTan);
        }
        if(rayAngle==0 || rayAngle==PI) {
            rayLocation[0] = playerX;
            rayLocation[1] = playerY;
            depth = 8;
            printf("bruh %f %f %i %i %f\n", rayLocation[0], rayLocation[1], yo, xo, aTan);
        }
        while(depth < 8) {
            mx = (int) (rayLocation[0]) >> 6;
            my = (int) (rayLocation[1]) >> 6;
            mp = my*mapX+mx;
            if(mp < mapX*mapY && map[mp]==1) {depth=8;}
            else {
                rayLocation[0] += xo;
                rayLocation[1] += yo;
                depth++;
            }
        }
    }
}