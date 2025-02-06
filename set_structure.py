import os

def create_folder_structure(base_path):
    structure = [
        'assets/models',
        'assets/textures',
        'assets/sounds',
        'assets/animations',
        'assets/shaders',
        'assets/ui',
        'scenes/world',
        'scenes/player',
        'scenes/ui',
        'scenes/quests',
        'scenes/structures',
        'scenes/multiplayer',
        'scripts/world',
        'scripts/player',
        'scripts/resources',
        'scripts/npc',
        'scripts/structures',
        'scripts/multiplayer'
    ]

    for folder in structure:
        path = os.path.join(base_path, folder)
        if not os.path.exists(path):
            os.makedirs(path)
            
            with open(os.path.join(path, '.gitkeep'), 'w') as f:
                pass
            print(f'Created: {path} with .gitkeep')
        else:
            print(f'Already exists: {path}')

if __name__ == "__main__":
    base_path = '.'
    create_folder_structure(base_path)
