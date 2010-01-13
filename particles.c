#include <assert.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#ifdef __APPLE__
#include "OpenGL/gl.h"
#include "OpenGL/glu.h"
#else
#include "GL/gl.h"
#include "GL/glu.h"
#endif

#define emitter_udata "particles.emitter"
#define PARTICLE_COUNT 2000

typedef struct {
    int life;
    float x;
    float y;
    float xvel;
    float yvel;
} particle_t;

typedef struct {
    int next;
    particle_t particles[PARTICLE_COUNT];
} emitter_t;

static inline void draw_particle(emitter_t *emitter, particle_t *particle)
{
    if(particle->life)
    {
        glColor4d(1, particle->life / 60.0, 1, particle->life / 60.0);
        glVertex2d(particle->x - 4, particle->y - 4);
        glVertex2d(particle->x + 4, particle->y - 4);
        glVertex2d(particle->x + 4, particle->y + 4);
        glVertex2d(particle->x - 4, particle->y + 4);
    }
}

static int emitter__draw(lua_State *L)
{
    emitter_t *emitter = luaL_checkudata(L, 1, "particles.emitter");
    int i;

    glBegin(GL_QUADS);
    for(i = emitter->next; i != PARTICLE_COUNT; i++)
        draw_particle(emitter, &emitter->particles[i]);
    for(i = 0; i != emitter->next; i++)
        draw_particle(emitter, &emitter->particles[i]);
    glEnd();

    glColor3d(1, 1, 1);

    return 0;
}

static int emitter__update(lua_State *L)
{
    emitter_t *emitter = luaL_checkudata(L, 1, emitter_udata);

    particle_t *particle;
    for(particle = emitter->particles;
        particle != emitter->particles + PARTICLE_COUNT;
        particle++)
    {
        if(particle->life)
        {
            particle->life--;
            particle->x += particle->xvel;
            particle->y += particle->yvel;
        }
    }

    return 0;
}

static int emitter__add_particle(lua_State *L)
{
    emitter_t *emitter = luaL_checkudata(L, 1, emitter_udata);
    float x = (float)luaL_checknumber(L, 2);
    float y = (float)luaL_checknumber(L, 3);
    float xvel = (float)luaL_checknumber(L, 4);
    float yvel = (float)luaL_checknumber(L, 5);

    // grab a particle slot from the emitter
    particle_t *particle = &emitter->particles[emitter->next];
    emitter->next = (emitter->next + 1) % PARTICLE_COUNT;

    // initialize it
    particle->life = 60;
    particle->x = x;
    particle->y = y;
    particle->xvel = xvel;
    particle->yvel = yvel;

    return 0;
}

static int particles__make_emitter(lua_State *L)
{
    printf("123");
    emitter_t *emitter = lua_newuserdata(L, sizeof(emitter_t));
    luaL_getmetatable(L, emitter_udata);
    lua_setmetatable(L, -2);

    emitter->next = 0;
    int i;
    for(i = 0; i < PARTICLE_COUNT; i++)
    {
        emitter->particles[i].life = 0;
    }

    return 1;
}

static const luaL_reg emitter_lib[] =
{
    {"draw", emitter__draw},
    {"update", emitter__update},
    {"add_particle", emitter__add_particle},
    {NULL, NULL}
};

static const luaL_Reg particles_lib[] =
{
    {"make_emitter", particles__make_emitter},
    {NULL, NULL}
};

int luaopen_particles(lua_State *L)
{
    luaL_newmetatable(L, "particles.emitter");
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_register(L, NULL, emitter_lib);

    lua_newtable(L);
    luaL_register(L, NULL, particles_lib);
    return 1;
}

