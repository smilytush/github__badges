interface User {
    id: number;
    name: string;
    email: string;
    isActive: boolean;
}

class UserManager {
    private users: User[] = [];
    
    constructor(initialUsers: User[] = []) {
        this.users = initialUsers;
    }
    
    addUser(user: User): void {
        this.users.push(user);
        console.log(User  added successfully);
    }
    
    getActiveUsers(): User[] {
        return this.users.filter(user => user.isActive);
    }
    
    getUserById(id: number): User | undefined {
        return this.users.find(user => user.id === id);
    }
}

// Example usage
const manager = new UserManager();
manager.addUser({ id: 1, name: 'John Doe', email: 'john@example.com', isActive: true });
const activeUsers = manager.getActiveUsers();
console.log(activeUsers);
// Updated on 2025-04-25 08:06:15 - Session: morning
// Updated on 2025-04-25 21:55:58 - Session: afternoon
// Updated on 2025-04-26 10:21:34 - Session: morning
