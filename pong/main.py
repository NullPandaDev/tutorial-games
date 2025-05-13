import pygame, random, sys

class GameState:
    def __init__(self, screen_width, screen_height) -> None:
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.ball = pygame.Rect(screen_width/2 -15, screen_height/2 - 15, 30, 30)
        self.player = pygame.Rect(screen_width - 20, screen_height/2 - 70, 10, 140)
        self.opponent = pygame.Rect(10, screen_height/2 - 70, 10, 140)
        self.ball_speed_x = 7
        self.ball_speed_y = 7
        self.player_speed_y = 0
        self.player_speed_x = 0
        self.hit_sfx = pygame.mixer.Sound('sounds/blip-131856.mp3')
        self.loss_sfx = pygame.mixer.Sound("sounds/retro-falling-down-sfx-85575.mp3")
        self.player_score = 0
        self.opponent_score = 0
        self.game_over = False
    
    def __update_ball_pos(self):
        if self.game_over:
            # self.ball.x = -100
            self.ball_speed_x = 0
            self.ball_speed_y = 0
            return

        self.ball.x += self.ball_speed_x
        self.ball.y += self.ball_speed_y
    
    def __update_player_pos(self):
        self.player.y += self.player_speed_y
        
        if self.player.top <= 0:
            self.player.y = 0
        if self.player.bottom >= self.screen_height:
            self.player.bottom = self.screen_height
    
        # self.player.x += self.player_speed_x
        # if self.player.left <= 0:
        #     self.player.x = 0
        # if self.player.right <= self.screen_width/2 + 20:
        #     self.player.x = self.screen_width/2 + 20

    def __check_collision(self):
        if self.ball.top <= 0 or self.ball.bottom >= self.screen_height:
            self.ball_speed_y *= -1
        if self.ball.left <= 0 or self.ball.right >= self.screen_width:
            self.ball_speed_x *= -1
        
        if self.ball.colliderect(self.player) or self.ball.colliderect(self.opponent):
            self.hit_sfx.play()
            self.ball_speed_x *= -1
    
    def __opponent_ai(self):
        if self.game_over:
            self.player_speed_y = 0
            return

        mid = ((self.opponent.top + self.opponent.bottom) /2)
        if mid > self.ball.y:
            self.opponent.y -= 6
        elif mid < self.ball.y:
            self.opponent.y += 6

        if self.opponent.top < 0:
            self.opponent.y = 0
        if self.opponent.bottom >= self.screen_height:
            self.opponent.bottom = self.screen_height
    
    def update_player_speed(self, event):
        if self.game_over:
            return

        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_DOWN:
                game_state.player_speed_y = 7
            elif event.key == pygame.K_UP:
                game_state.player_speed_y = -7
        elif event.type == pygame.KEYUP:
            if event.key == pygame.K_DOWN:
                game_state.player_speed_y = 0 # FIXME: Would be nice if this slowed to a hault
            elif event.key == pygame.K_UP:
                game_state.player_speed_y = 0
            # elif event.key == pygame.K_LEFT:
            #     game_state.player_speed_x = -7
            # elif event.key == pygame.K_RIGHT:
            #     game_state.player_speed_x = 7

    def __win_or_loose(self):
        if self.ball.left <= 0:
            self.ball.x = screen_width/2 -15
            self.ball.y = screen_height/2
            self.ball_speed_x = random.choice([7, -7])
            self.ball_speed_y = random.choice([7, -7])
            self.loss_sfx.play()
            self.player_score += 1
        if self.ball.right >= self.screen_width:
            self.ball.x = screen_width/2 -15
            self.ball.y = screen_height/2
            self.ball_speed_x = random.choice([7, -7])
            self.ball_speed_y = random.choice([7, -7])
            self.loss_sfx.play()
            self.opponent_score += 1
    
        if self.player_score >= 5 or self.opponent_score >= 1:
            self.game_over = True
    
    def draw_scores(self):
        text = font.render(f'{self.opponent_score}', True, color=(255, 255, 255))
        screen.blit(text, (30, 30))

        text = font.render(f'{self.player_score}', True, color=(255, 255, 255))
        screen.blit(text, (self.screen_width-30, 30))

        if self.game_over:
            text = font.render(f'GAME OVER', True, color=(255, 255, 255))
            screen.blit(text, (self.screen_width/2-65, self.screen_height/2))


    def tick(self):
        self.__opponent_ai() # Unnecessary spice
        self.__update_ball_pos()
        self.__update_player_pos()
        self.__win_or_loose()
        self.__check_collision()

pygame.init()
clock = pygame.time.Clock()

screen_width = 1280
screen_height = 960
screen = pygame.display.set_mode((screen_width, screen_height))
pygame.display.set_caption('Pong')




bg_color = pygame.Color('grey12')
light_grey = (200,200,200)


game_state = GameState(screen_width, screen_height)

font = pygame.font.Font(None, size=30)
while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        
        game_state.update_player_speed(event)


    # text = font.render('0', True, (255, 2, 0))

    
    game_state.tick()


    # draw
    screen.fill(bg_color)
    pygame.draw.rect(screen, light_grey, game_state.player)
    pygame.draw.rect(screen, light_grey, game_state.opponent)
    if not game_state.game_over:
        pygame.draw.ellipse(screen, light_grey, game_state.ball)
    pygame.draw.aaline(screen, light_grey, (screen_width/2,0), (screen_width/2, screen_height))
    
    game_state.draw_scores()


    pygame.display.flip()
    clock.tick(60)
