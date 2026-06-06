package todo.app.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import todo.app.model.Todo;

@Repository
public interface TodoRepository extends JpaRepository<Todo, Long> {
}
