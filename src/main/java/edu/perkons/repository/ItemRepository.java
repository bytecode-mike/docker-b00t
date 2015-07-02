package edu.perkons.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import edu.perkons.model.Item;
import org.springframework.stereotype.Repository;

@Repository
public interface ItemRepository extends JpaRepository<Item, Integer> {
}
