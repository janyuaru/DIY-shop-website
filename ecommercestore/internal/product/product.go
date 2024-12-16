package product

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"strings"
	"time"

	_ "github.com/lib/pq"
)

type Product struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Price       float64   `json:"price"`
	ShopID      string    `json:"shop_id"`
	CategoryID  int       `json:"category_id"`
	ProductType string    `json:"product_type"`
	IsFeatured  string    `json:"is_featured"`
	SKU         string    `json:"sku"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type NewProduct struct {
	ID          string  `json:"id"`
	Name        string  `json:"product_name"`
	Description string  `json:"description"`
	Price       float64 `json:"price"`
	ShopID      string  `json:"shop_id"`
	CategoryID  int     `json:"category_id"`
	ProductType string  `json:"product_type"`
	IsFeatured  string  `json:"is_featured"`
	SKU         string  `json:"sku"`
}

// `json:"id"`
type ProductImage struct {
	ID        string    `json:"id"`
	ProductID string    `json:"product_id"`
	ImageURL  string    `json:"image_url"`
	IsPrimary bool      `json:"is_primary"`
	SortOrder int       `json:"sort_order"`
	CreatedAt time.Time `json:"created_at"`
}

type ProductQueryParams struct {
	Limit       int    `json:"limit"`
	Search      string `json:"search"`
	CategoryID  int    `json:"category_id"`
	ShopID      string `json:"shop_id"`
	IsFeatured  string `json:"is_featured"`
	ProductType string `json:"product_type"`
	Sort        string `json:"sort"`
	Order       string `json:"order"`
}

type ProductResponse struct {
	Items []ProductItem `json:"items"`
	Limit int           `json:"limit"`
}

type ProductItem struct {
	Product
	Categories []Category      `json:"categories"`
	Shops      []Shop          `json:"shops"`
	Inventory  Inventory       `json:"inventory"`
	Images     []ProductImage  `json:"images"`
	Options    []ProductOption `json:"options"`
}

type Category struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type Shop struct {
	ShopID      string `json:"shop_id"`
	ShopName    string `json:"shopname"`
	Description string `json:"description"`
	Province    string `json:"province"`
	Phone       string `json:"phone"`
	Email       string `json:"email"`
	ImageURL    string `json:"image_url"`
}

type Inventory struct {
	Quantity  int       `json:"quantity"`
	UpdatedAt time.Time `json:"updated_at"`
}

type ProductOption struct {
	ID     string `json:"id"`
	Name   string `json:"name"`
	Values string `json:"values"`
}

type EcommerceDatabase interface {
	GetProduct(ctx context.Context, id string) (ProductItem, error)
	GetProducts(ctx context.Context, params ProductQueryParams) (*ProductResponse, error)
	GetProductImages(ctx context.Context, productID string) ([]ProductImage, error)
	GetShops(ctx context.Context, shopID string) ([]Shop, error)
	GetCategories(ctx context.Context) ([]Category, error)
	GetprodCategory(ctx context.Context, id string, sort string, order string) ([]ProductItem, error)
	Close() error
	Ping() error
	Reconnect(connStr string) error
}

type PostgresDatabase struct {
	db *sql.DB
}

func NewPostgresDatabase(connStr string) (*PostgresDatabase, error) {
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %v", err)
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %v", err)
	}

	return &PostgresDatabase{db: db}, nil
}

func (pdb *PostgresDatabase) GetCategories(ctx context.Context) ([]Category, error) {
	rows, err := pdb.db.QueryContext(ctx, "SELECT category_id, category_name FROM categories")

	if err != nil {
		return nil, fmt.Errorf("failed to get category: %v", err)
	}
	defer rows.Close()
	var cats []Category
	for rows.Next() {
		var cat Category
		if err := rows.Scan(
			&cat.ID, &cat.Name); err != nil {
			return nil, fmt.Errorf("failed to scan category: %v", err)
		}
		cats = append(cats, cat)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("rows iteration error: %v", err)
	}

	return cats, nil
}

func (pdb *PostgresDatabase) GetprodCategory(ctx context.Context, id string, sort string, order string) ([]ProductItem, error) {
	var products []ProductItem

	if sort == "" {
		sort = "price"
	}
	if order == "" {
		order = "asc"
	}
	if order != "asc" && order != "desc" {
		return nil, fmt.Errorf("invalid order value: %s, expected 'asc' or 'desc'", order)
	}

	query := fmt.Sprintf(`
        SELECT p.product_id, p.product_name, p.description, p.price, p.shop_id, p.product_type, p.is_featured,
               p.created_at, p.updated_at, c.category_id, c.category_name, i.quantity, i.updated_at, s.name, s.image_url
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.category_id
        LEFT JOIN inventory i ON p.product_id = i.product_id
        LEFT JOIN shops s ON p.shop_id = s.shop_id
        WHERE p.category_id = $1
        ORDER BY p.%s %s`, sort, order)

	rows, err := pdb.db.QueryContext(ctx, query, id)
	if err != nil {
		return nil, fmt.Errorf("failed to query products: %v", err)
	}
	defer rows.Close()

	for rows.Next() {
		var product ProductItem
		var category Category
		var inventory Inventory
		var shop Shop

		err := rows.Scan(
			&product.ID, &product.Name, &product.Description, &product.Price,
			&product.ShopID, &product.ProductType, &product.IsFeatured, &product.CreatedAt,
			&product.UpdatedAt, &category.ID, &category.Name,
			&inventory.Quantity, &inventory.UpdatedAt, &shop.ShopName, &shop.ImageURL)

		// เพิ่มข้อมูล Category, Inventory, Shop ลงใน Product
		product.Categories = []Category{category}
		product.Inventory = inventory
		product.Shops = []Shop{shop}

		// ดึงข้อมูลรูปภาพของสินค้า
		product.Images, err = pdb.GetProductImages(ctx, product.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product images: %v", err)
		}

		// ดึงข้อมูลตัวเลือกสินค้า (ถ้ามี)
		product.Options, err = pdb.getProductOptions(ctx, product.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product options: %v", err)
		}

		// ตรวจสอบหากมีข้อผิดพลาดจากการวนลูป
		if err := rows.Err(); err != nil {
			return nil, fmt.Errorf("failed to iterate rows: %v", err)
		}

		// เพิ่ม product ลงใน slice
		products = append(products, product)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate rows: %v", err)
	}

	if len(products) == 0 {
		return []ProductItem{}, nil
	}

	return products, nil
}

func (pdb *PostgresDatabase) GetProduct(ctx context.Context, id string) (ProductItem, error) {
	var product ProductItem
	var category Category
	var inventory Inventory
	var shop Shop

	err := pdb.db.QueryRowContext(ctx, `
		SELECT p.product_id, p.product_name, p.description, p.price, p.shop_id, p.product_type, p.is_featured,
			p.created_at, p.updated_at, c.category_id, c.category_name, i.quantity, i.updated_at, s.name, s.image_url
		FROM products p
		LEFT JOIN categories c ON p.category_id = c.category_id
		LEFT JOIN inventory i ON p.product_id = i.product_id
		LEFT JOIN shops s ON p.shop_id = s.shop_id
		WHERE p.product_id = $1
	`, id).Scan(
		&product.ID, &product.Name, &product.Description, &product.Price,
		&product.ShopID, &product.ProductType, &product.IsFeatured, &product.CreatedAt,
		&product.UpdatedAt, &category.ID, &category.Name,
		&inventory.Quantity, &inventory.UpdatedAt, &shop.ShopName, &shop.ImageURL)

	if err != nil {
		if err == sql.ErrNoRows {
			return ProductItem{}, fmt.Errorf("product not found")
		}
		return ProductItem{}, fmt.Errorf("failed to get product: %v", err)
	}

	product.Categories = []Category{category}

	err = pdb.db.QueryRowContext(ctx, `
		SELECT quantity, updated_at
		FROM inventory
		WHERE product_id = $1
	`, id).Scan(&product.Inventory.Quantity, &product.Inventory.UpdatedAt)

	if err != nil && err != sql.ErrNoRows {
		return ProductItem{}, fmt.Errorf("failed to get inventory: %v", err)
	}

	product.Images, err = pdb.GetProductImages(ctx, id)
	if err != nil {
		return ProductItem{}, fmt.Errorf("failed to get product images: %v", err)
	}

	product.Shops, err = pdb.GetShops(ctx, product.ShopID)
	if err != nil {
		return ProductItem{}, fmt.Errorf("failed to get product images: %v", err)
	}

	product.Options, err = pdb.getProductOptions(ctx, id)
	if err != nil {
		return ProductItem{}, fmt.Errorf("failed to get product options: %v", err)
	}

	return product, nil
}

func (pdb *PostgresDatabase) GetProducts(ctx context.Context, params ProductQueryParams) (*ProductResponse, error) {
	query := `
		SELECT p.product_id, p.product_name, p.description, p.price, p.shop_id, p.product_type, p.is_featured,
			p.created_at, p.updated_at, c.category_id, c.category_name, i.quantity, i.updated_at, s.name, s.image_url
		FROM products p
		LEFT JOIN categories c ON p.category_id = c.category_id
		LEFT JOIN inventory i ON p.product_id = i.product_id
		LEFT JOIN shops s ON p.shop_id = s.shop_id
		WHERE 1=1
	`
	args := []interface{}{}
	placeholderCount := 1

	if params.Search != "" {
		query += fmt.Sprintf(" AND (p.product_name ILIKE $%d OR p.description ILIKE $%d)", placeholderCount, placeholderCount+1)
		args = append(args, "%"+params.Search+"%", "%"+params.Search+"%")
		placeholderCount += 2
	}

	if params.CategoryID != 0 {
		query += fmt.Sprintf(" AND p.category_id = $%d", placeholderCount)
		args = append(args, params.CategoryID)
		placeholderCount++
	}

	if params.ShopID != "" {
		query += fmt.Sprintf(" AND p.shop_id = $%d", placeholderCount)
		args = append(args, params.ShopID)
		placeholderCount++
	}

	if params.IsFeatured != "" {
		query += fmt.Sprintf(" AND p.is_featured = $%d", placeholderCount)
		args = append(args, params.IsFeatured)
		placeholderCount++
	}

	if params.ProductType != "" {
		query += fmt.Sprintf(" AND p.product_type = $%d", placeholderCount)
		args = append(args, params.ProductType)
		placeholderCount++
	}

	sortFields := map[string]string{
		"name":       "p.product_name",
		"price":      "p.price",
		"created_at": "p.created_at",
	}

	orderDirections := map[string]string{
		"asc":  "ASC",
		"desc": "DESC",
	}

	sortColumn, ok := sortFields[params.Sort]
	if !ok {
		sortColumn = "p.created_at"
	}

	orderDirection, ok := orderDirections[strings.ToLower(params.Order)]
	if !ok {
		orderDirection = "ASC"
	}

	query += fmt.Sprintf(" ORDER BY %s %s, p.product_id ASC", sortColumn, orderDirection)

	limit := 25
	if params.Limit > 0 && params.Limit <= 100 {
		limit = params.Limit
	}
	query += fmt.Sprintf(" LIMIT $%d", placeholderCount)
	args = append(args, limit)
	placeholderCount++

	rows, err := pdb.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to get products: %v", err)
	}
	defer rows.Close()

	var products []ProductItem
	for rows.Next() {
		var product ProductItem
		var category Category
		var inventory Inventory
		var shop Shop
		if err := rows.Scan(
			&product.ID, &product.Name, &product.Description, &product.Price,
			&product.ShopID, &product.ProductType, &product.IsFeatured, &product.CreatedAt,
			&product.UpdatedAt, &category.ID, &category.Name,
			&inventory.Quantity, &inventory.UpdatedAt, &shop.ShopName, &shop.ImageURL); err != nil {
			return nil, fmt.Errorf("failed to scan product: %v", err)
		}

		product.Categories = []Category{category}
		product.Inventory = inventory

		product.Images, err = pdb.GetProductImages(ctx, product.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product images: %v", err)
		}

		product.Shops, err = pdb.GetShops(ctx, product.ShopID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product images: %v", err)
		}

		product.Options, err = pdb.getProductOptions(ctx, product.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product options: %v", err)
		}

		products = append(products, product)

	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate over products: %v", err)
	}

	response := &ProductResponse{
		Items: products,
	}

	return response, nil
}

func (pdb *PostgresDatabase) GetShops(ctx context.Context, shopID string) ([]Shop, error) {
	rows, err := pdb.db.QueryContext(ctx, `
		SELECT shop_id, name, description, province, phone, 
			email, image_url FROM shops WHERE shop_id = $1
	`, shopID)
	if err != nil {
		return nil, fmt.Errorf("failed to get shops: %v", err)
	}
	defer rows.Close()

	var shops []Shop
	for rows.Next() {
		var shop Shop
		if err := rows.Scan(
			&shop.ShopID, &shop.ShopName, &shop.Description, &shop.Province,
			&shop.Phone, &shop.Email, &shop.ImageURL); err != nil {
			return nil, fmt.Errorf("failed to scan shop: %v", err)
		}
		shops = append(shops, shop)
	}
	if err := rows.Err(); err != nil {
		log.Printf("Error iterating over products: %v", err)
		return nil, fmt.Errorf("failed to iterate over shops: %v", err)
	}

	return shops, nil
}

func (pdb *PostgresDatabase) GetProductImages(ctx context.Context, productID string) ([]ProductImage, error) {
	rows, err := pdb.db.QueryContext(ctx, `
		SELECT image_id, product_id, image_url, is_primary, sort_order, created_at 
		FROM product_images 
		WHERE product_id = $1
	`, productID)
	if err != nil {
		return nil, fmt.Errorf("failed to get product images: %v", err)
	}
	defer rows.Close()
	var images []ProductImage
	for rows.Next() {
		var image ProductImage
		if err := rows.Scan(
			&image.ID, &image.ProductID, &image.ImageURL, &image.IsPrimary,
			&image.SortOrder, &image.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan product image: %v", err)
		}
		images = append(images, image)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating over products: %v", err)
		return nil, fmt.Errorf("failed to iterate over products: %v", err)
	}

	return images, nil
}

func (pdb *PostgresDatabase) Close() error {
	return pdb.db.Close()
}

func (pdb *PostgresDatabase) Ping() error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	return pdb.db.PingContext(ctx)
}

func (pdb *PostgresDatabase) getProductOptions(ctx context.Context, productID string) ([]ProductOption, error) {
	rows, err := pdb.db.QueryContext(ctx, `
        SELECT option_id, name, values
        FROM product_options
        WHERE product_id = $1
    `, productID)
	if err != nil {
		return nil, fmt.Errorf("failed to get product options: %v", err)
	}
	defer rows.Close()

	var options []ProductOption
	for rows.Next() {
		var option ProductOption
		if err := rows.Scan(&option.ID, &option.Name, &option.Values); err != nil {
			return nil, fmt.Errorf("failed to scan product option: %v", err)
		}
		options = append(options, option)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate over product options: %v", err)
	}

	return options, nil
}

func (pdb *PostgresDatabase) Reconnect(connStr string) error {
	if pdb.db != nil {
		pdb.db.Close()
	}

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %v", err)
	}

	// ตั้งค่า connection pool
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return fmt.Errorf("failed to ping database: %v", err)
	}

	pdb.db = db
	return nil
}

type Store struct {
	db EcommerceDatabase
}

func NewStore(db EcommerceDatabase) *Store {
	return &Store{db: db}
}

func (s *Store) GetCategories(ctx context.Context) ([]Category, error) {
	return s.db.GetCategories(ctx)
}

func (s *Store) GetprodCategory(ctx context.Context, id string, sort string, order string) ([]ProductItem, error) {
	return s.db.GetprodCategory(ctx, id, sort, order)
}

func (s *Store) GetProduct(ctx context.Context, id string) (ProductItem, error) {
	return s.db.GetProduct(ctx, id)
}

func (s *Store) GetProducts(ctx context.Context, params ProductQueryParams) (*ProductResponse, error) {
	return s.db.GetProducts(ctx, params)
}

func (s *Store) GetShops(ctx context.Context, shopID string) ([]Shop, error) {
	return s.db.GetShops(ctx, shopID)
}

func (s *Store) GetProductImages(ctx context.Context, productID string) ([]ProductImage, error) {
	return s.db.GetProductImages(ctx, productID)
}

func (s *Store) Close() error {
	return s.db.Close()
}

func (s *Store) Ping() error {
	if s.db == nil {
		return fmt.Errorf("database connection is not initialized")
	}
	return s.db.Ping()
}

func (s *Store) Reconnect(connStr string) error {
	return s.db.Reconnect(connStr)
}
