package handlers

import (
	"ecommercestore/internal/product"
	"log"
	"net/http"

	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type ProductHandlers struct {
	store *product.Store
}

func NewProductHandlers(store *product.Store) *ProductHandlers {
	return &ProductHandlers{store: store}
}

func convertTimesToUserTimezone(product *product.ProductItem, loc *time.Location) {
	product.CreatedAt = product.CreatedAt.In(loc)
	product.UpdatedAt = product.UpdatedAt.In(loc)
	product.Inventory.UpdatedAt = product.Inventory.UpdatedAt.In(loc)

	for j := range product.Images {
		product.Images[j].CreatedAt = product.Images[j].CreatedAt.In(loc)
	}
}

func (h *ProductHandlers) GetProducts(c *gin.Context) {
	limitStr := c.DefaultQuery("limit", "25")
	limit, err := strconv.Atoi(limitStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid limit value"})
		return
	}

	categoryIDStr := c.Query("category")
	var categoryID int
	if categoryIDStr != "" {
		categoryID, err = strconv.Atoi(categoryIDStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid category ID"})
			return
		}
	}

	params := product.ProductQueryParams{
		Limit:       limit,
		Search:      c.Query("search"),
		CategoryID:  categoryID,
		ShopID:      c.Query("shop_id"),
		IsFeatured:  c.Query("is_featured"),
		ProductType: c.Query("product_type"),
		Sort:        c.Query("sort"),
		Order:       c.Query("order"),
	}

	response, err := h.store.GetProducts(c.Request.Context(), params)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	userTimezone := "Asia/Bangkok"
	loc, err := time.LoadLocation(userTimezone)
	if err != nil {
		log.Fatal("ไม่สามารถโหลด timezone ได้:", err)
	}

	for i := range response.Items {
		convertTimesToUserTimezone(&response.Items[i], loc)
	}

	c.JSON(http.StatusOK, response)
}

func (h *ProductHandlers) GetProduct(c *gin.Context) {
	id := c.Param("id")

	product, err := h.store.GetProduct(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}
	userTimezone := "Asia/Bangkok"
	loc, err := time.LoadLocation(userTimezone)
	if err != nil {
		log.Fatal("ไม่สามารถโหลด timezone ได้:", err)
	}

	convertTimesToUserTimezone(&product, loc)

	c.JSON(http.StatusOK, product)
}

func (h *ProductHandlers) GetprodCategory(c *gin.Context) {
	id := c.Param("id")
	sort := c.DefaultQuery("sort", "price")
	order := c.DefaultQuery("order", "asc")

	products, err := h.store.GetprodCategory(c.Request.Context(), id, sort, order)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	userTimezone := "Asia/Bangkok"
	loc, err := time.LoadLocation(userTimezone)
	if err != nil {
		log.Fatal("ไม่สามารถโหลด timezone ได้:", err)
	}

	// แปลงเวลาให้กับทุก ProductItem ใน products
	for i := range products {
		convertTimesToUserTimezone(&products[i], loc)
	}

	c.JSON(http.StatusOK, products)
}

func (h *ProductHandlers) GetProductImages(c *gin.Context) {
	id := c.Param("id") // รับค่า id เป็น string

	images, err := h.store.GetProductImages(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, images)
}

func (h *ProductHandlers) GetShops(c *gin.Context) {
	id := c.Param("id")
	shop, err := h.store.GetShops(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, shop)
}

func (h *ProductHandlers) GetCategories(c *gin.Context) {
	categories, err := h.store.GetCategories(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve categories"})
		return
	}
	c.JSON(http.StatusOK, categories)
}

func (h *ProductHandlers) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "healthy"})
}
