// Code generated by lister-gen. DO NOT EDIT.

package v1alpha1

import (
	v1alpha1 "github.com/clusterpedia-io/api/policy/v1alpha1"
	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/client-go/tools/cache"
)

// PediaClusterLifecycleLister helps list PediaClusterLifecycles.
// All objects returned here must be treated as read-only.
type PediaClusterLifecycleLister interface {
	// List lists all PediaClusterLifecycles in the indexer.
	// Objects returned here must be treated as read-only.
	List(selector labels.Selector) (ret []*v1alpha1.PediaClusterLifecycle, err error)
	// Get retrieves the PediaClusterLifecycle from the index for a given name.
	// Objects returned here must be treated as read-only.
	Get(name string) (*v1alpha1.PediaClusterLifecycle, error)
	PediaClusterLifecycleListerExpansion
}

// pediaClusterLifecycleLister implements the PediaClusterLifecycleLister interface.
type pediaClusterLifecycleLister struct {
	indexer cache.Indexer
}

// NewPediaClusterLifecycleLister returns a new PediaClusterLifecycleLister.
func NewPediaClusterLifecycleLister(indexer cache.Indexer) PediaClusterLifecycleLister {
	return &pediaClusterLifecycleLister{indexer: indexer}
}

// List lists all PediaClusterLifecycles in the indexer.
func (s *pediaClusterLifecycleLister) List(selector labels.Selector) (ret []*v1alpha1.PediaClusterLifecycle, err error) {
	err = cache.ListAll(s.indexer, selector, func(m interface{}) {
		ret = append(ret, m.(*v1alpha1.PediaClusterLifecycle))
	})
	return ret, err
}

// Get retrieves the PediaClusterLifecycle from the index for a given name.
func (s *pediaClusterLifecycleLister) Get(name string) (*v1alpha1.PediaClusterLifecycle, error) {
	obj, exists, err := s.indexer.GetByKey(name)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NewNotFound(v1alpha1.Resource("pediaclusterlifecycle"), name)
	}
	return obj.(*v1alpha1.PediaClusterLifecycle), nil
}
