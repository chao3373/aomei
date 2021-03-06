package com.shenke.service.impl;

import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import javax.annotation.Resource;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;
import javax.persistence.criteria.*;

import com.shenke.entity.*;
import com.shenke.repository.*;
import com.shenke.util.DateUtil;
import com.shenke.util.EntityUtils;
import com.shenke.util.StringUtil;
import org.springframework.beans.BeanUtils;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.shenke.service.StorageService;

/**
 * 入库单Service实现类
 *
 * @author Administrator
 */
@Service("storageService")
@Transactional
public class StorageServiceImpl implements StorageService {

    @Resource
    private StorageRepository storageRepository;

    @PersistenceContext
    private EntityManager entityManager;

    @Resource
    private SaleListProductRepository saleListProductRepository;

    @Resource
    private JitaiProductionAllotRepository jitaiProductionAllotRepository;

    @Resource
    private JiTaiRepository jiTaiRepository;

    @Resource
    private ClerkRepository clerkRepository;

    @Resource
    private GroupRepository groupRepository;

    @Override
    public void add(Storage storage, String clerkName, String groupName) {

        Group group = groupRepository.findByGrouptName(groupName);
        SaleListProduct saleListProduct = saleListProductRepository.findOne(storage.getSaleListProduct().getId());
        Clerk clerk = clerkRepository.findByNam(clerkName);
        Double realityweight = storage.getRealityweight();

        BeanUtils.copyProperties(saleListProduct, storage);
        storage.setId(null);
        storage.setClerk(clerk);
        storage.setGroup(group);
        storage.setRealityweight(realityweight);
        storage.setDateInProduced(new Date(System.currentTimeMillis()));
        storage.setSaleNumber(saleListProduct.getSaleList().getSaleNumber());
        storage.setState("生产完成:" + storage.getJiTai().getName());
        storage.setJiTaiName(storage.getJiTai().getName());
        storage.setClerkName(clerkName);
        storage.setGroup(storage.getJiTai().getGroup());
        storage.setGroupName(storage.getJiTai().getGroup().getName());
        storageRepository.save(storage);

    }

    @Override
    public void feibiaoAdd(Storage storage, String clerkName, String groupName) {

        Group group = groupRepository.findByGrouptName(groupName);
        SaleListProduct saleListProduct = saleListProductRepository.findOne(storage.getSaleListProduct().getId());
        Clerk clerk = clerkRepository.findByNam(clerkName);
        Double realityweight = storage.getRealityweight();

        BeanUtils.copyProperties(saleListProduct, storage);
        storage.setId(null);
        storage.setClerk(clerk);
        storage.setGroup(group);
        storage.setRealityweight(realityweight);
        storage.setDateInProduced(new Date(System.currentTimeMillis()));
        storage.setState("生产完成:" + storage.getJiTai().getName());
        storage.setJiTaiName(storage.getJiTai().getName());
        storage.setClerkName(clerkName);
        storage.setGroup(storage.getJiTai().getGroup());
        storage.setGroupName(storage.getJiTai().getGroup().getName());
        storage.setSaleListProduct(null);
        storageRepository.save(storage);

    }

    @Override
    public List<Storage> fandAll() {
        return storageRepository.findAll();
    }

    @Override
    public List<Storage> fandAllBySerialNumber(String serialNumber, String state) {
        return storageRepository.fandAllBySerialNumber(serialNumber, state);
    }

    @Override
    public Storage selectByMaxId() {
        return storageRepository.selectByMaxId();
    }

    @Override
    public void outStorage(int id, Date date) {
        // TODO Auto-generated method stub
        storageRepository.outStorage(id, date);
    }

    @Override
    public List<Storage> outSuccess() {
        // TODO Auto-generated method stub
        return storageRepository.outSuccess();
    }


    @Override
    public void gai(String storage_number, int id) {
        // TODO Auto-generated method stub
        storageRepository.gai(storage_number, id);
    }

    @Override
    public void updateStateById(String state, Integer id, java.util.Date date) {
        storageRepository.updateStateById(state, id, date);
    }

    @Override
    public List<Object[]> findByClientAndGroupByName(String client) {
        List<Object[]> byClientAndGroupByName = storageRepository.findByClientAndGroupByName(client);
        return byClientAndGroupByName;
    }

    @Override
    public List<Storage> findAll() {
        return storageRepository.findAll();
    }

    @Override
    public Storage findById(Integer s) {
        return storageRepository.findOne(s);
    }

    @Override
    public List<JieSuan> FindByGroup(String client) {
        System.out.println(client);
        System.out.println(storageRepository.FindByGroup(client));
        List<JieSuan> castEntity = EntityUtils.castEntity(storageRepository.FindByGroup(client), JieSuan.class);
        return castEntity;
    }

    @Override
    public List<Storage> searchLiftMoney(Map<String, Object> map) {
        return storageRepository.findAll(new Specification<Storage>() {
            @Override
            public Predicate toPredicate(Root<Storage> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                Predicate predicate = cb.conjunction();
                if (StringUtil.isNotEmpty((String) map.get("saleNumber"))) {
                    predicate.getExpressions().add(cb.equal(root.get("saleNumber"), (String) map.get("saleNumber")));
                }
                /*if (map.get("location") != null) {
                    predicate.getExpressions().add(cb.equal(root.get("location").get("id"), map.get("location")));
                }
                if (map.get("jitai") != null) {
                    predicate.getExpressions().add(cb.equal(root.get("jiTai").get("id"), map.get("jitai")));
                }*/
                if (StringUtil.isNotEmpty((String) map.get("productDate"))) {
                    try {
                        predicate.getExpressions().add(cb.equal(root.get("dateInProduced"), new SimpleDateFormat("yyy-MM-dd").parse((String) map.get("productDate"))));
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }
                /*
                if (map.get("clerk") != null) {
                    predicate.getExpressions().add(cb.equal(root.get("clerk").get("id"), map.get("clerk")));
                }
                if (map.get("group") != null) {
                    predicate.getExpressions().add(cb.equal(root.get("group").get("id"), map.get("group")));
                }
                */
                if (StringUtil.isNotEmpty((String) map.get("peasant"))) {
                    predicate.getExpressions().add(cb.equal(root.get("peasant"), map.get("peasant")));
                }
                if (StringUtil.isNotEmpty((String) map.get("realityweight"))) {
                    predicate.getExpressions().add(cb.equal(root.get("realityweight"), map.get("realityweight")));
                }
                if (StringUtil.isNotEmpty((String) map.get("name"))) {
                    predicate.getExpressions().add(cb.equal(root.get("name"), map.get("name")));
                }
                if (StringUtil.isNotEmpty((String) map.get("client"))) {
                    predicate.getExpressions().add(cb.equal(root.get("clientname"), map.get("client")));
                }
                if (StringUtil.isNotEmpty((String) map.get("mode"))) {
                    predicate.getExpressions().add(cb.equal(root.get("model"), map.get("mode")));
                }
                if (StringUtil.isNotEmpty((String) map.get("price"))) {
                    predicate.getExpressions().add(cb.equal(root.get("price"), map.get("price")));
                }
                Subquery subQuery = query.subquery(String.class);

                Root from = subQuery.from(Storage.class);
                subQuery.select(from.get("id")).where(cb.like(from.get("state"), "%生产完成%"));
//                Predicate state1 = cb.like(from.get("state"), "%装车%");
//                Predicate state = cb.like(from.get("state"), "%提货%");
//                Predicate or = cb.or(state1);

                predicate.getExpressions().add(cb.or(root.get("id").in(subQuery)));

                return predicate;
            }
        });
    }

    @Override
    public void setLocation(Integer parseInt, Integer location) {
        storageRepository.setLocation(parseInt, location);
    }

    @Override
    public void save(Storage storage) {
        storageRepository.save(storage);
    }

    @Override
    public void save(Storage storage, Integer num) {
        if (num != null) {
            for (int i = 0; i < num; i++) {
                Storage storage1 = new Storage();
                storage1.setName(storage.getName());
                storage1.setModel(storage.getModel());
                storage1.setPrice(storage.getPrice());
                storage1.setLength(storage.getLength());
                storage1.setColor(storage.getColor());
                storage1.setWeight(storage.getWeight());
                storage1.setDao(storage.getDao());
                storage1.setBrand(storage.getBrand());
                storage1.setPack(storage.getPack());
                storage1.setLetter(storage.getLetter());
                storage1.setPatu(storage.getPatu());
                storage1.setMeter(storage.getMeter());
                storage1.setClientname(storage.getClientname());
                storage1.setState(storage.getState());
                storage1.setLocation(storage.getLocation());
                storageRepository.save(storage1);
            }
        }
    }

    @Override
    public List<Storage> findByState(String state) {
        return storageRepository.findByState(state);
    }

    @Override
    public List<StorageOut> detail(Map<String, Object> map) {
        String client = (String) map.get("client");
        String de = (String) map.get("startDate");
        String ed = (String) map.get("endDate");
        System.out.println(de);
        java.util.Date startDate = null;
        java.util.Date endDate = null;
        if (StringUtil.isNotEmpty(de)) {
            try {
                startDate = new SimpleDateFormat("yyyy-MM-dd").parse(de);
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
        if (StringUtil.isNotEmpty(ed)) {
            try {
                endDate = new SimpleDateFormat("yyyy-MM-dd").parse(ed);
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
        String peasant = (String) map.get("peasant");
        String product = (String) map.get("product");
        String order = (String) map.get("order");

        CriteriaBuilder criteriaBuilder = entityManager.getCriteriaBuilder();
        CriteriaQuery<StorageOut> query = criteriaBuilder.createQuery(StorageOut.class);
        Root<Storage> from = query.from(Storage.class);
        Path<String> clientname = from.get("clientname");
        Path<String> peasant1 = from.get("peasant");
        Path<String> name = from.get("name");
        Path<String> color = from.get("color");
        Path<String> outNumber = from.get("outNumber");
        Path<Double> model = from.get("model");
        Path<Double> price = from.get("price");
        Path<Double> length = from.get("length");
        Path<Integer> dabaonum = from.get("dabaonum");
        Path<Double> realityweight = from.get("realityweight");
        Path<Integer> saleListProductId = from.get("saleListProduct").get("id");
        Path<java.util.Date> deliveryTime = from.get("deliveryTime");


        List<Predicate> predicateList = new ArrayList<Predicate>();
        if (StringUtil.isNotEmpty(client)) {
            predicateList.add(criteriaBuilder.equal(clientname, client));
        }
        if (StringUtil.isNotEmpty(peasant)) {
            predicateList.add(criteriaBuilder.equal(peasant1, peasant));
        }
        if (StringUtil.isNotEmpty(product)) {
            predicateList.add(criteriaBuilder.equal(name, product));
        }
        if (startDate != null && endDate != null) {
            predicateList.add(criteriaBuilder.greaterThanOrEqualTo(deliveryTime, startDate));
            predicateList.add(criteriaBuilder.lessThanOrEqualTo(deliveryTime, endDate));
        }

        predicateList.add(criteriaBuilder.equal(from.get("state"), "装车"));

        Predicate[] predicates = new Predicate[predicateList.size()];
        predicates = predicateList.toArray(predicates);

        query.where(predicates);

        query.groupBy(saleListProductId, name, model, length, color, realityweight);

        if (StringUtil.isNotEmpty((String) map.get("order"))) {
            query.orderBy(criteriaBuilder.asc(from.get((String) map.get("order")).as(String.class)));
        }

        query.multiselect(clientname, peasant1, name, color, outNumber, model, price, length, realityweight, criteriaBuilder.sum(realityweight).as(Double.class), criteriaBuilder.count(name).as(Integer.class), deliveryTime, dabaonum);
        TypedQuery<StorageOut> q = entityManager.createQuery(query);
        List<StorageOut> resultList = q.getResultList();
        for (StorageOut storageOut : resultList) {
            System.out.println(storageOut);
        }
        return resultList;


//        if (map.get("order") != null && map.get("order") != "") {
//            return storageRepository.findAll(new Specification<Storage>() {
//                public Predicate toPredicate(Root<Storage> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
//                    Predicate predicate = cb.conjunction();
//                    if (map.get("date") != null) {
//                        predicate.getExpressions().add(cb.equal(root.get("deliveryTime"), map.get("date")));
//                    }
//                    if (StringUtil.isNotEmpty((String) map.get("client"))) {
//                        predicate.getExpressions().add(cb.like(root.get("clientname"), "%" + map.get("client") + "%"));
//                    }
//                    if (StringUtil.isNotEmpty((String) map.get("peasant"))) {
//                        predicate.getExpressions().add(cb.like(root.get("peasant"), "%" + map.get("peasant") + "%"));
//                    }
//                    if (StringUtil.isNotEmpty((String) map.get("product"))) {
//                        predicate.getExpressions().add(cb.like(root.get("name"), "%" + map.get("product") + "%"));
//                    }
//
//                    predicate.getExpressions().add(cb.like(root.get("state"), "%装车%"));
//
//                    query.groupBy(root.get("saleListProduct").get("id"));
//
//                    return predicate;
//                }
//            }, new Sort(Sort.Direction.ASC, (String) map.get("order")));
//        }
//        return storageRepository.findAll(new Specification<Storage>() {
//            @Override
//            public Predicate toPredicate(Root<Storage> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
//                Predicate predicate = cb.conjunction();
//                if (map.get("date") != null) {
//                    predicate.getExpressions().add(cb.equal(root.get("deliveryTime"), map.get("date")));
//                }
//                if (StringUtil.isNotEmpty((String) map.get("client"))) {
//                    predicate.getExpressions().add(cb.like(root.get("clientname"), "%" + map.get("client") + "%"));
//                }
//                if (StringUtil.isNotEmpty((String) map.get("peasant"))) {
//                    predicate.getExpressions().add(cb.like(root.get("peasant"), "%" + map.get("peasant") + "%"));
//                }
//                if (StringUtil.isNotEmpty((String) map.get("product"))) {
//                    predicate.getExpressions().add(cb.like(root.get("name"), "%" + map.get("product") + "%"));
//                }
//
//                predicate.getExpressions().add(cb.like(root.get("state"), "%装车%"));
//
//                query.groupBy(root.get("saleListProduct").get("id"));
//                return predicate;
//            }
//        });
    }

    @Override
    public List<Storage> selectClientNameByOutDate(Date s) {
        return storageRepository.selectClientNameByOutDate(s);
    }

    @Override
    public List<StorageOut> selectOutByOutNumber(String outNumber) {
        List<Object[]> list = storageRepository.selectOutByOutNumber(outNumber);
        List<StorageOut> list1 = new ArrayList<>();
        for (Object[] obj : list) {
            try {
                list1.add(new StorageOut(obj[0].toString(), obj[1].toString(), obj[2].toString(), obj[3].toString(), obj[4].toString(), Double.parseDouble(obj[5].toString()), Double.parseDouble(obj[6].toString()), Double.parseDouble(obj[7].toString()), Double.parseDouble(obj[8].toString()), Double.parseDouble(obj[9].toString()), Integer.parseInt(obj[10].toString()), new SimpleDateFormat("yyyy-MM-dd").parse(obj[11].toString()), Integer.parseInt(obj[12].toString())));
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
        return list1;
    }

    @Override
    public String selectCountByNameAndOutNumber(String name, String outNumber) {
        return storageRepository.selectCountByNameAndOutNumber(name, outNumber);
    }

    /***
     *
     * 根据
     * @param
     * @return
     */
    @Override
    public List<Count> FindBySaleListId() {
        List<Count> cast = EntityUtils.castEntity(storageRepository.FindBySaleListId(), Count.class);
        return cast;
    }

    @Override
    public Integer countBySaleListProductId(Integer id) {
        Long count = storageRepository.count(new Specification<Storage>() {
            @Override
            public Predicate toPredicate(Root<Storage> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                List<Predicate> predicates = new ArrayList<>();
                if (id != null && id != 0) {
                    predicates.add(cb.equal(root.get("saleListProduct").get("id"), id));
                }
                return query.where(predicates.toArray(new Predicate[predicates.size()])).getRestriction();
            }
        });
        return count.intValue();
    }

    public List<Storage> findSaleListNumber() {
        return storageRepository.findSaleListNumber();
    }

    @Override
    public List<Storage> findStorage(String saleNumber) {
        return storageRepository.findStorage(saleNumber);
    }


    @Override
    public List<Storage> KucunSearch(Map<String, Object> map) {
        return storageRepository.findAll(new Specification<Storage>() {
            @Override
            public Predicate toPredicate(Root<Storage> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                Predicate predicate = cb.conjunction();
                if (StringUtil.isNotEmpty((String) map.get("saleDate"))) {
                    try {
                        predicate.getExpressions().add(cb.equal(root.get("saleList").get("saleDate"), new SimpleDateFormat("yyy-MM-dd").parse((String) map.get("saleDate"))));
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }
                if (map.get("clientname") != null) {
                    predicate.getExpressions().add(cb.equal(root.get("clientname"), map.get("clientname")));
                }
                if ((map.get("saleNumber") != null)) {
                    predicate.getExpressions().add(cb.equal(root.get("saleNumber"), map.get("saleNumber")));
                }

                return predicate;
            }
        });
    }


    @Override
    public List<Storage> JitaiProduct(Storage storage, java.util.Date date, java.util.Date star, java.util.Date end) {
        return storageRepository.findAll(new Specification<Storage>() {
            @Override
            public Predicate toPredicate(Root<Storage> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                Predicate predicate = cb.conjunction();
                if (StringUtil.isNotEmpty(storage.getGroupName())) {
                    predicate.getExpressions().add(cb.equal(root.get("groupName"), storage.getGroupName()));
                }
                if (StringUtil.isNotEmpty(storage.getJiTaiName())) {
                    predicate.getExpressions().add(cb.equal(root.get("jiTaiName"), storage.getJiTaiName()));
                }
                if (StringUtil.isNotEmpty(storage.getGroupName())) {
                    predicate.getExpressions().add(cb.equal(root.get("groupName"), storage.getGroupName()));
                }
                if (star != null) {
                    System.out.println("开始时间");
                    System.out.println(star);
                    predicate.getExpressions().add(cb.greaterThanOrEqualTo(root.get("dateInProduced"), star));
                }
                if (end != null) {
                    System.out.println("结束时间");
                    System.out.println(end);
                    predicate.getExpressions().add(cb.lessThanOrEqualTo(root.get("dateInProduced"), end));
                }
                return predicate;
            }
        });
    }

    @Override
    public List<Storage> select(Storage storage, String dateInProducedd) {
        return storageRepository.findAll(new Specification<Storage>() {
            @Override
            public Predicate toPredicate(Root<Storage> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                Predicate predicate = cb.conjunction();
                if (StringUtil.isNotEmpty(storage.getSaleNumber())) {
                    predicate.getExpressions().add(cb.like(root.get("saleNumber"), "%" + storage.getSaleNumber() + "%"));
                }
                if (storage.getLocation() != null) {
                    predicate.getExpressions().add(cb.equal(root.get("location").get("id"), storage.getLocation().getId()));
                }
                if (storage.getJiTai() != null) {
                    predicate.getExpressions().add(cb.equal(root.get("jiTai").get("id"), storage.getJiTai().getId()));
                }
                if (StringUtil.isNotEmpty(storage.getPeasant())) {
                    predicate.getExpressions().add(cb.equal(root.get("peasant"), storage.getPeasant()));
                }
                if (StringUtil.isNotEmpty(dateInProducedd)) {
                    try {
                        java.util.Date star = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(dateInProducedd + " 00:00:00");
                        java.util.Date end = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(dateInProducedd + " 23:59:59");
                        predicate.getExpressions().add(cb.greaterThanOrEqualTo(root.get("dateInProduced"), star));
                        predicate.getExpressions().add(cb.lessThanOrEqualTo(root.get("dateInProduced"), end));
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }
                if (storage.getGroup() != null) {
                    predicate.getExpressions().add(cb.equal(root.get("group"), storage.getGroup()));
                }
                if (storage.getClerk() != null) {
                    predicate.getExpressions().add(cb.equal(root.get("clerk").get("id"), storage.getClerk().getId()));
                }
                if (StringUtil.isNotEmpty(storage.getClientname())) {
                    predicate.getExpressions().add(cb.equal(root.get("clientname"), storage.getClientname()));
                }
                if (storage.getLength() != null) {
                    predicate.getExpressions().add(cb.equal(root.get("length"), storage.getLength()));
                }
                if (storage.getModel() != null) {
                    predicate.getExpressions().add(cb.equal(root.get("model"), storage.getModel()));
                }
                if (storage.getPrice() != null) {
                    predicate.getExpressions().add(cb.equal(root.get("price"), storage.getPrice()));
                }
                if (storage.getRealityweight() != null) {
                    predicate.getExpressions().add(cb.equal(root.get("realityweight"), storage.getRealityweight()));
                }
                predicate.getExpressions().add(cb.like(root.get("state"), "%生产完成%"));
                return predicate;
            }
        });
    }

    @Override
    public void updateByIdAndState(int parseInt, String state) {
        storageRepository.updateByIdAndState(parseInt, state);
    }

    @Override
    public List<Storage> selectByState(String state) {
        return storageRepository.selectByState("%" + state + "%");
    }

    @Override
    public void updateOutNumberById(int parseInt, String ck) {
        storageRepository.updateOutNumberById(ck, parseInt);
    }

    @Override
    public String genCode() throws Exception {
        StringBuffer code = new StringBuffer("CK");
        code.append(DateUtil.getCurrentDateStr());
        String saleNumber = storageRepository.getTodayMaxOutNumber();
        if (saleNumber != null) {
            code.append(StringUtil.formatCode(saleNumber));
        } else {
            code.append("00001");
        }
        return code.toString();
    }

    @Override
    public void editKuCun(Integer id, Integer oneWeight, Double shiji, Double length) {
        storageRepository.editKuCun(id, oneWeight, shiji, length);
    }

    @Override
    public List<Storage> findeBySaleNumberAndClient(String saleNumber, String client) {
        return storageRepository.findAll(new Specification<Storage>() {
            @Override
            public Predicate toPredicate(Root<Storage> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                Predicate predicate = cb.conjunction();
                if (StringUtil.isNotEmpty(saleNumber)) {
                    predicate.getExpressions().add(cb.like(root.get("saleNumber"), "%" + saleNumber + "%"));
                }
                if (StringUtil.isNotEmpty(client)) {
                    predicate.getExpressions().add(cb.equal(root.get("clientname"), client));
                }
                return predicate;
            }
        });
    }

    /***
     *
     * 按月查询报表
     * @param month
     * @param year
     * @return
     */
    @Override
    public Month selectMonth(String month, String year) {
        Month month1 = new Month();
        String m = Integer.parseInt(month) < 10 ? 0 + month : month;
        Integer month2 = Integer.parseInt(month) + 1;
        String m1 = month2 < 10 ? 0 + month2 + "" : month2 + "";
        String date = year + "-" + m + "-01";
        String date1 = year + "-" + m1 + "-01";
        try {
            java.util.Date udate = new SimpleDateFormat("yyyy-MM-dd").parse(date);
            java.util.Date endate = new SimpleDateFormat("yyyy-MM-dd").parse(date1);
            System.out.println(date);
            System.out.println(date1);
            month1.setLastMonth(storageRepository.lastMonth(udate));
            month1.setMonthIn(storageRepository.monthIn(udate, endate));
            month1.setMonthOut(storageRepository.monthOut(udate, endate));
            return month1;
        } catch (ParseException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public Month selectYear(String year) {
        Integer lastYear = Integer.parseInt(year) + 1;
        Month month = new Month();
        try {
            java.util.Date n = new SimpleDateFormat("yyyy-MM-dd").parse(year + "-01-01");
            java.util.Date n1 = new SimpleDateFormat("yyyy-MM-dd").parse(lastYear + "-01-01");
            System.out.println(n);
            System.out.println(n1);
            month.setLastMonth(storageRepository.lastMonth(n));
            month.setMonthIn(storageRepository.monthIn(n, n1));
            month.setMonthOut(storageRepository.monthOut(n, n1));
            return month;
        } catch (ParseException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public void updateClerkAndGroup(Integer clerkid, String clerkname, Integer groupid, String groupname, int parseInt) {
        Storage one = storageRepository.findOne(parseInt);
        one.setGroupName(groupname);
        Group group = new Group();
        group.setId(groupid);
        Clerk clerk = new Clerk();
        clerk.setId(clerkid);
        one.setGroup(group);
        one.setClerkName(clerkname);
        one.setClerk(clerk);
        storageRepository.save(one);
    }
}
