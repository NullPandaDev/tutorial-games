import pygame, random, sys
from enum import Enum

class Snake:
    def __init__(self):
        self.segments = [pygame.Rect(20, 20, 20, 20), pygame.Rect(40, 20, 20, 20), pygame.Rect(60, 20, 20, 20), pygame.Rect(60, 40, 20, 20)]
        self.direction = Direction.NONE

class Direction(Enum):
    UP = 1
    RIGHT = 2
    LEFT = 3
    DOWN = 4
    NONE = 5

class GameState:
    screen_width = 300
    screen_height = screen_width
    block_size = 20
    bg_color = (200,200,200)
    white = (255,255,255)
    light_grey = pygame.Color('grey12')
    red = (247, 56, 49)

    def __init__(self) -> None:
        self.snake = Snake()
        self.__apple()
        self.screen = pygame.display.set_mode((GameState.screen_width, GameState.screen_height))
        self.game_over = False

    def __apple(self):
            # x = random.randint(0, (GameState.screen_width-GameState.block_size) // GameState.block_size) * GameState.block_size
            # y = random.randint(0, (GameState.screen_height-GameState.block_size) // GameState.block_size) * GameState.block_size
            # self.apple = pygame.Rect(x, y, GameState.block_size, GameState.block_size)

            flag = True
            while flag: # FIXME: This is fucky
                x = random.randint(0, (GameState.screen_width-GameState.block_size) // GameState.block_size) * GameState.block_size
                y = random.randint(0, (GameState.screen_height-GameState.block_size) // GameState.block_size) * GameState.block_size
                self.apple = pygame.Rect(x, y, GameState.block_size, GameState.block_size)

                flag = False
                for segment in self.snake.segments:
                    if segment.x == self.apple.x and segment.y == self.apple.y:
                        flag = True
                        break
    
    
    def monitor_inputs(self, event):
        # if event.type == pygame.KEYDOWN:
        #     return {
        #         pygame.K_UP: Direction.UP,
        #         pygame.K_RIGHT: Direction.RIGHT,
        #         pygame.K_DOWN: Direction.DOWN,
        #         pygame.K_LEFT: Direction.LEFT,
        #     }.get(event.key, self.snake.direction)
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_UP and Direction.DOWN != self.snake.direction:
                self.snake.direction = Direction.UP
            elif event.key == pygame.K_RIGHT and Direction.LEFT != self.snake.direction:
                self.snake.direction = Direction.RIGHT
            elif event.key == pygame.K_DOWN and Direction.UP != self.snake.direction:
                self.snake.direction = Direction.DOWN
            elif event.key == pygame.K_LEFT and Direction.RIGHT != self.snake.direction:
                self.snake.direction = Direction.LEFT

    def __detect_collision(self):
        x = self.snake.segments[-1].x
        y = self.snake.segments[-1].y
        if x >= GameState.screen_width or x < 0 or y >= GameState.screen_height or y < 0:
            self.snake.direction = Direction.NONE
            if not self.game_over:
                loss_sfx.play()
            self.game_over = True
        
        for segment in self.snake.segments[:-1]:
            if segment.x == x and segment.y == y:
                self.snake.direction = Direction.NONE
                if not self.game_over:
                    loss_sfx.play()
                self.game_over = True
        

    def __update_snake(self):
        if Direction.NONE == self.snake.direction:
            return

        for i in range(len(self.snake.segments)-1):
            self.snake.segments[i].x = self.snake.segments[i+1].x
            self.snake.segments[i].y = self.snake.segments[i+1].y

        if Direction.UP == self.snake.direction:
            self.snake.segments[-1].y -= GameState.block_size
        elif Direction.RIGHT == self.snake.direction:
            self.snake.segments[-1].x += GameState.block_size
        elif Direction.DOWN == self.snake.direction:
            self.snake.segments[-1].y += GameState.block_size
        elif Direction.LEFT == self.snake.direction:
            self.snake.segments[-1].x -= GameState.block_size

    def __eat(self):
        if self.snake.segments[-1].colliderect(self.apple):
            self.snake.segments.append(pygame.Rect(self.apple.x, self.apple.y, GameState.block_size, GameState.block_size))
            self.__apple()
            eat_sfx.play()

    def tick(self):
        self.__eat() # Fixme: should you come after?
        self.__update_snake()
        self.__detect_collision()

    
    def __draw_background(self):
        self.screen.fill(state.bg_color)

        # FIXME: Really ugly if logic to print checkered board
        for y in range(0, GameState.screen_width, GameState.block_size):
            for x in range(0, GameState.screen_width, GameState.block_size):
                if (x / GameState.block_size) % 2 == 0:
                    if (y / GameState.block_size) % 2 == 0:
                        pygame.draw.rect(self.screen, (122, 252, 98), pygame.Rect(x, y, GameState.block_size, GameState.block_size))
                    else:
                        pygame.draw.rect(self.screen, (83, 171, 67), pygame.Rect(x, y, GameState.block_size, GameState.block_size))
                else:
                    if (y / GameState.block_size) % 2 == 0:
                        pygame.draw.rect(self.screen, (83, 171, 67), pygame.Rect(x, y, GameState.block_size, GameState.block_size))
                    else:
                        pygame.draw.rect(self.screen, (122, 252, 98), pygame.Rect(x, y, GameState.block_size, GameState.block_size))

    def draw(self):
        self.__draw_background()
        pygame.draw.rect(self.screen, GameState.red, self.apple)
        for segment in self.snake.segments:
            if segment == self.snake.segments[-1]:
                pygame.draw.rect(self.screen, GameState.white, segment)
            else:
                pygame.draw.rect(self.screen, GameState.light_grey, segment)

        text = font.render(f'{len(self.snake.segments)}', True, color=(255, 255, 255))
        self.screen.blit(text, (0, 0))

        if self.game_over:
            text = font.render(f'GAME OVER', True, color=(255, 255, 255))
            self.screen.blit(text, (self.screen_width/2-70, self.screen_height/2-20))



pygame.init()
clock = pygame.time.Clock()

state = GameState()


pygame.display.set_caption('Snake')

font = pygame.font.Font(None, size=30)
eat_sfx = pygame.mixer.Sound('sounds\eat-323883.mp3')
loss_sfx = pygame.mixer.Sound("sounds/retro-falling-down-sfx-85575.mp3")


while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        state.monitor_inputs(event)
        
    state.tick()

    # draw
    state.draw()


    pygame.display.flip()
    clock.tick(5)
