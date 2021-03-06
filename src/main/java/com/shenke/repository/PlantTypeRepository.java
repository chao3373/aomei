package com.shenke.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import com.shenke.entity.PlantType;

/**
 * 厂商关系Repository
 * 
 * @author Administrator
 *
 */
public interface PlantTypeRepository extends JpaRepository<PlantType, Integer>, JpaSpecificationExecutor<PlantType> {
	/**
	 * 根据父节点查询所有子节点
	 * 
	 * @param parentId
	 * @return
	 */
	@Query(value = "select * from t_planttype where p_id=?1", nativeQuery = true)
	public List<PlantType> findByParentId(Integer parentId);
}
